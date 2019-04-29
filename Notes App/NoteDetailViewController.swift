//
//  NoteDetailViewController.swift
//  Notes App
//
//  Created by Gerjan te Velde on 29/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    //MARK: - Objects and Properties
    var note: String?
    weak var delegate: NotesTableViewController!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextView.text = note ?? ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate.newOrEditedNote(noteTextView.text!)
    }
}
