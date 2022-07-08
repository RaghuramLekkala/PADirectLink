//
//  SocketIOManager.swift
//  IOSChatBot
//
//  Created by Raghuram on 07/06/22.
//

import UIKit

class SocketManager: NSObject, URLSessionWebSocketDelegate {
    
    static var isOpened: Bool = false
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
        SocketManager.isOpened = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
        SocketManager.isOpened = false
    }
}




