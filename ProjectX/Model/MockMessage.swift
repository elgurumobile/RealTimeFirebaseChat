//
//  MockMessage.swift
//  Msn
//
//  Created by Felipe Aragon on 28/05/18.
//  Copyright © 2018 Felipe Aragon. All rights reserved.
//

import Foundation
import MessageKit

internal struct MockMessage: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var data: MessageData
    var timestamp : TimeInterval
    
    private init(kind: MessageData, sender: Sender, messageId: String, date: Date, timestamp: TimeInterval) {
        self.data = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.timestamp = timestamp
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date,timestamp: TimeInterval) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date, timestamp: timestamp)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date,timestamp: TimeInterval) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, timestamp: timestamp)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date,timestamp: TimeInterval) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date, timestamp: timestamp)
    }
    
}
