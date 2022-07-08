//
//  Message.swift
//  IOSChatBot
//
//  Created by Raghuram on 25/05/22.
//

import Foundation
import MessageKit

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

public struct Message:MessageType {
     public var sender: SenderType
    
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind
    
    public var sectionCount: Int?
    
    
    init(sender:SenderType, messageId:String, kind:MessageKind , sentDate: Date, sectionCount: Int?) {
        self.sender = sender
        self.messageId = messageId
        self.kind = kind
        self.sentDate = sentDate
        self.sectionCount = sectionCount
    }
}
