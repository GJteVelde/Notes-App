//
//  NotesTableViewController.swift
//  Notes App
//
//  Created by Gerjan te Velde on 29/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

enum recordAction {
    case add
    case update
    case delete
}

class NotesTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var notes = [Note]()
    var lastTimeLoadNotesFromCloudCalled: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotesFromCloud()
    }

    //MARK: - Table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.text
        cell.detailTextLabel?.text = "Last edited: " + note.lastEditedAsString()
        
        return cell
    }
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedNote = notes.remove(at: indexPath.row)
            submitNoteToCloud(removedNote, action: .delete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Segues and delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? NoteDetailViewController else { return }
        destinationVC.delegate = self
        
        if segue.identifier == "EditNoteSegue" {
            let selectedNote = notes[tableView.indexPathForSelectedRow!.row]
            destinationVC.note = selectedNote
        }
    }
    
    func sendNoteToNotesTableVC(_ note: Note) {
        if let indexPathOfEditedNote = tableView.indexPathForSelectedRow {
            notes.remove(at: indexPathOfEditedNote.row)
            notes.insert(note, at: 0)
            
            tableView.performBatchUpdates({
                tableView.moveRow(at: indexPathOfEditedNote, to: IndexPath(row: 0, section: 0))
            }) { [unowned self] (_) in
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            
            submitNoteToCloud(note, action: .update)
        } else {
            notes.insert(note, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            submitNoteToCloud(note, action: .add)
        }
    }
    
    //MARK: - Data storage and retrieval
    func loadNotesFromCloud() {
        if let lastTimeLoadedNotes = UserDefaults.standard.object(forKey: "lastTimeLoadedNotes") as? Date {
            if lastTimeLoadedNotes > Date().addingTimeInterval(-15*60) {
                print("Notes are recently updated and therefore not updated again.")
                return
            }
        }
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "lastEdited", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["text", "lastEdited"]
        
        var loadedNotes = [Note]()
        
        operation.recordFetchedBlock = { (record) in
            let note = Note()
            note.recordID = record.recordID
            note.text = record["text"]
            note.lastEdited = record["lastEdited"]
            loadedNotes.append(note)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("loadNotesFromCloud(): queryCompletionBlock: \(error.localizedDescription)")
                } else {
                    UserDefaults.standard.set(Date(), forKey: "lastTimeLoadedNotes")
                    self.notes = loadedNotes
                    self.tableView.reloadData()
                }
            }
        }
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        privateDatabase.add(operation)
    }
    
    func submitNoteToCloud(_ note: Note, action: recordAction) {
        //TODO: Check if iCloud is enabled.
        
        let noteRecord = CKRecord(recordType: "Note", recordID: note.recordID)
        noteRecord["text"] = note.text as CKRecordValue
        noteRecord["lastEdited"] = note.lastEdited as CKRecordValue
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        switch action {
        case .add:
            privateDatabase.save(noteRecord) { (record, error) in
                if let error = error {
                    print("SubMiteNoteToCloud(): Addition failed: \(error.localizedDescription).")
                } else {
                    print("SubmitNoteToCloud(): Addition succeeded.")
                }
            }
        case .update:
            privateDatabase.fetch(withRecordID: noteRecord.recordID) { (fetchedRecord, error) in
                if let fetchedRecord = fetchedRecord {
                    
                    fetchedRecord.setObject(noteRecord["text"], forKey: "text")
                    fetchedRecord.setObject(noteRecord["lastEdited"], forKey: "lastEdited")
                    
                    privateDatabase.save(fetchedRecord, completionHandler: { (record, error) in
                        if let error = error {
                            print("SubmitNoteToCloud(): Update record failed (save): \(error.localizedDescription).")
                        } else {
                            print("SubmitNoteToCloud(): Update succeeded (save).")
                        }
                    })
                } else if let error = error {
                    print("SubmitNoteToCloud(): Update failed (fetch): \(error.localizedDescription).")
                }
            }
        case .delete:
            let deleteOperation = CKModifyRecordsOperation()
            deleteOperation.savePolicy = .ifServerRecordUnchanged
            deleteOperation.recordIDsToDelete = [noteRecord.recordID]
            
            deleteOperation.modifyRecordsCompletionBlock = { (records, ids, error) in
                if let error = error {
                    print("SubmitNoteToCloud(): Deletion failed: \(error.localizedDescription).")
                } else {
                    print("SubmitNoteToCloud(): Deletion succeeded.")
                }
            }
            
            privateDatabase.add(deleteOperation)
        }
    }
}
