//
//  Note.swift
//  Notes App
//
//  Created by Gerjan te Velde on 30/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit

class Note: NSObject {
    var recordID: CKRecord.ID!    
    var text: String!
    
    //TODO: Replace lastEdited with CKRecord.modificationDate?
    var lastEdited: Date!
}

extension Note {
    func lastEditedAsString() -> String {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        let lastWeekDate = calendar.startOfDay(for: Date()).addingTimeInterval(-6 * 24 * 60 * 60)
        
        if calendar.isDateInToday(lastEdited) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: lastEdited)
        } else if calendar.isDateInYesterday(lastEdited) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: lastEdited)
        } else if lastWeekDate < lastEdited {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
            return dateFormatter.string(from: lastEdited)
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: lastEdited)
        }
    }
}
