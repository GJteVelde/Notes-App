//
//  Note.swift
//  Notes App
//
//  Created by Gerjan te Velde on 30/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

class Note: NSObject, NSCoding {
    
    enum Keys: String {
        case text = "Text"
        case lastEdited = "lastEdited"
    }
    
    var text: NSAttributedString
    var lastEdited: Date
    
    init(text: NSAttributedString, lastEdited: Date) {
        self.text = text
        self.lastEdited = lastEdited
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: Keys.text.rawValue)
        aCoder.encode(lastEdited, forKey: Keys.lastEdited.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObject(forKey: Keys.text.rawValue) as! NSAttributedString
        let lastEdited = aDecoder.decodeObject(forKey: Keys.lastEdited.rawValue) as! Date
        self.init(text: text, lastEdited: lastEdited)
    }
}
