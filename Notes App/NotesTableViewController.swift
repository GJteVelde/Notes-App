//
//  NotesTableViewController.swift
//  Notes App
//
//  Created by Gerjan te Velde on 29/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadNotes()
    }

    //MARK: - Table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.text.string
        cell.detailTextLabel?.text = "Last edited: " + returnDateAsString(note.lastEdited)
        
        return cell
    }
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveNotes()
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
        } else {
            notes.insert(note, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        saveNotes()
    }
    
    //MARK: - Data storage and retrieval
    func loadNotes() {
        guard let codedData = try? Data(contentsOf: filePath()) else { return }
        
        do {
            if let encodedNotes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as? [Note] {
                notes = encodedNotes
                tableView.reloadData()
            }
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }
    
    func saveNotes() {
        do {
            let codedNotes = try NSKeyedArchiver.archivedData(withRootObject: notes, requiringSecureCoding: false)
            try codedNotes.write(to: filePath())
        } catch {
            let alert = UIAlertController(title: "Could not save notes", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func filePath() -> URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("Notes")
    }
    
    //MARK: - Helper Methods
    func returnDateAsString(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        let lastWeekDate = calendar.startOfDay(for: Date()).addingTimeInterval(-6 * 24 * 60 * 60)
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: date)
        } else if lastWeekDate < date {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
    }
}
