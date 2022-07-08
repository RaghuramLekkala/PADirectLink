//
//  ChatViewController.swift
//  IOSChatBot
//
//  Created by Raghuram on 24/05/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    private var messages: [Message] = []
    let apiManager = ApiManager()
    let network = Netwotking()
    let alert = UIAlertController(title: "No internet detected", message: "Please connect to internet", preferredStyle: .alert)
    var cid:String = ""
    var senderNameValue: String?
    var uuid: String?
    private let webSocketDelegate = SocketManager()
    private var  webSocketTask:URLSessionWebSocketTask?
    private var tokenVal = ""
    var attachments : [Attachments]?


    //MARK: - InsertNewMessage
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == currentSender().senderId
    }
    
    //MARK: Receive
    func receive(){
        let workItem = DispatchWorkItem{ [weak self] in
            self?.webSocketTask?.receive(completionHandler: { [self] result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        print("Data received \(data)")
                    case .string(let strMessgae):
                        let jsonData = strMessgae.data(using: .utf8)!
                        do {
                            let messagesReceived:ReceiveMessage = try JSONDecoder().decode(ReceiveMessage.self, from: jsonData)
                            if let destructuredMessages = messagesReceived.activities{
                        
                                DispatchQueue.main.async {
                                   
                                    self?.insertNewMessage(Message(sender: Sender(senderId: (destructuredMessages[0].from?.id)!, displayName: (destructuredMessages[0].from?.name)!), messageId: destructuredMessages[0].id!, kind: MessageKind.text(destructuredMessages[0].text!), sentDate:Date(), sectionCount: 1))
                                    
                                    if let attachments =  destructuredMessages[0].attachments{
                                        if attachments.count > 0 {
                                            self!.attachments = attachments
                                            self?.insertNewMessage(Message(sender: Sender(senderId: (destructuredMessages[0].from?.id)!, displayName: (destructuredMessages[0].from?.name)!), messageId: destructuredMessages[0].id!, kind: MessageKind.custom(attachments), sentDate:Date(), sectionCount: attachments.count))
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Error",error)
                        }
                    default:
                        break
                    }
                case .failure(let error):
                    print("Error Receiving \(error)")
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)}
                }
                // Creates the Recurrsion
                self?.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
    
    //MARK: - IsLastSectionVisible
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
 

    
    //MARK: - RemoveMessageAvatar
    private func removeMessageAvatars() {
        guard
            let layout = messagesCollectionView.collectionViewLayout
                as? MessagesCollectionViewFlowLayout
        else {
            return
        }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    
    
    
    //MARK: - CollectionView
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
            guard let messagesDataSource = messagesCollectionView.messagesDataSource  else {
                fatalError("Ouch. nil data source for messages")
            }
            //before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
            if isSectionReservedForTypingIndicator(indexPath.section){
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
       
            let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
                    if case .custom = message.kind {
                guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MyCell else {
                    fatalError()
                }
                cell.configure(with: attachments![indexPath.row])

            
                return cell
            }
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        
        messagesCollectionView = MessagesCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: MyCustomMessagesFlowLayout())
        messagesCollectionView.register(UINib(nibName: "MyCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        navigationItem.hidesBackButton = true

       //MARK: - NetworkAvailability

        if  network.isNetworkAvailable(){
            apiManager.post(endpoint: "/tokens/generate") { (token) in
                self.apiManager.post(endpoint: "/conversations", token: token){ (streamURL) in let url = URL(string: streamURL)!
                    let session = URLSession(configuration: .default, delegate: self.webSocketDelegate, delegateQueue: OperationQueue())
                    self.webSocketTask = session.webSocketTask(with: url)
                    self.webSocketTask?.resume()
                    
                }
            }
            
            if let
                cidVal = UserDefaults.standard.string(forKey: "CID"){
                cid = cidVal
            }
            
            if let
                tokenValue = UserDefaults.standard.string(forKey: "token"){
                tokenVal = tokenValue
            }
            
        } else{
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        removeMessageAvatars()
        receive()
        
    }
}

//MARK: - MessageDataSource
extension ChatViewController: MessagesDataSource{
    
    func currentSender() -> SenderType {
        return Sender(senderId: uuid!, displayName: senderNameValue!)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages[section].sectionCount!
    }
    
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath
    ) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
    
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    // 2
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        return 20
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .brown
    }
    
    func shouldDisplayHeader(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> Bool {
        return false
    }
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        avatarView.isHidden = true
    }
    
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
            isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(
        _ inputBar: InputBarAccessoryView,
        didPressSendButtonWith text: String
    ) {
        apiManager.post(endpoint:  "/conversations/\(cid)/activities", token: tokenVal, body: ["type": "message", "from": [
            "id": uuid!,
            "name": senderNameValue!
        ], "text": text]);
        inputBar.inputTextView.text = ""
    }
}



