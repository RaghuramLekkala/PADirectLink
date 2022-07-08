//
//  CustomMessageSizeCalculator.swift
//  IOSChatBot
//
//  Created by Raghuram on 10/06/22.
//

import UIKit
import MessageKit


open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
    // Customize this function implementation to size your content appropriately. This example simply returns a constant size
    // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically
    
        return CGSize(width: 400, height: 300)
    }
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        layout?.scrollDirection = .horizontal
        super.init(layout: layout)
        
       
    }

}
