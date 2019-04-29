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
    var notes = [String]()
    
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
        cell.textLabel?.text = notes[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedNote = notes.remove(at: sourceIndexPath.row)
        notes.insert(movedNote, at: destinationIndexPath.row)
        saveNotes()
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
    
    func newOrEditedNote(_ note: String) {
        guard note != "" else { return }
        
        if let indexPathOfEditedNote = tableView.indexPathForSelectedRow {
            notes[indexPathOfEditedNote.row] = note
            tableView.reloadRows(at: [indexPathOfEditedNote], with: .automatic)
        } else {
            notes.append(note)
            tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .automatic)
        }
        
        saveNotes()
    }
    
    //MARK: - Data storage and retrieval
    func loadNotes() {
        guard let codedData = try? Data(contentsOf: filePath()) else { return }
        
        do {
            if let encodedNotes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as? [String] {
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
}
