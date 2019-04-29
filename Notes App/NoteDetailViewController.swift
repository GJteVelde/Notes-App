//
//  NoteDetailViewController.swift
//  Notes App
//
//  Created by Gerjan te Velde on 29/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, UITextViewDelegate {

    //MARK: - Objects and Properties
    var note: NSAttributedString?
    weak var delegate: NotesTableViewController!
    
    @IBOutlet weak var noteTextView: UITextView!
    var doneBarButton: UIBarButtonItem!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonTapped))
        navigationItem.rightBarButtonItem = doneBarButton
        
        if note == nil {
            noteTextView.becomeFirstResponder()
            doneBarButton.isEnabled = true
        } else {
            doneBarButton.isEnabled = false
        }
        
        noteTextView.delegate = self
        noteTextView.allowsEditingTextAttributes = true
        noteTextView.attributedText = note ?? NSAttributedString()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate.newOrEditedNote(noteTextView.attributedText!)
    }
    
    //MARK: - Methods
    @objc func adjustKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = UIEdgeInsets.zero
        } else {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        noteTextView.scrollIndicatorInsets = noteTextView.contentInset
        
        let selectedRange = noteTextView.selectedRange
        noteTextView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func doneBarButtonTapped() {
        noteTextView.resignFirstResponder()
        doneBarButton.isEnabled = false
    }
    
    //MARK: - Delegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneBarButton.isEnabled = true
    }
}
