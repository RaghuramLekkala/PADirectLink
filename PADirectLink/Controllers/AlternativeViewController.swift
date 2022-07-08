//
//  AlternativeViewController.swift
//  IOSChatBot
//
//  Created by Raghuram on 16/06/22.
//

import UIKit
import MessageKit


protocol AlternativeViewControllerDelegate:class {
    func receive(_ controller: AlternativeViewController)
    func insertNewMessage(_ message: Message)
    func webSocketCall()
    func webSocketCallAgain()
}

class AlternativeViewController: UIViewController {
    
    

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var attachments: [Attachments] = []
    var actions: [Actions] = []
    
    private var url:URL?
    private var session: URLSession?
    
    static var streamURLVal = ""
    
    let screenWidth = UIScreen.main.bounds
    
    //MARK: - senderPressed
    @IBAction func sentButtonPressed(_ sender: UIButton) {
        if(messageTextField.text != ""){
            apiManager.post(endpoint:  "/conversations/\(ApiManager.cid)/activities", token: ApiManager.tokenVal, body: ["type": "message", "from": [
                "id": uuid!,
                "name": senderNameValue!
            ], "text": messageTextField.text!]);
        }
        messageTextField.text = ""
        tableView.reloadData()
    }
    //MARK: - networking
    let network = Netwotking()
    let alert = UIAlertController(title: "No internet detected", message: "Please connect to internet", preferredStyle: .alert)
    
    //MARK: - api
    let apiManager = ApiManager()
    
    //MARK: - User
    var senderNameValue: String?
    var uuid: String?
    
    //MARK: - WebSocket
    private let webSocketDelegate = SocketManager()
    private var  webSocketTask:URLSessionWebSocketTask?
    
    //MARK: - CurrentSender
    func currentSender() -> SenderType {
        return Sender(senderId: uuid!, displayName: senderNameValue!)
    }
    
    //MARK: - IsFromCurrentSender
    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == currentSender().senderId
    }
   
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Rose, Resident Mischief-Maker?"
        
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.tableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: K.tableViewCellIdentifier)
        tableView.register(MyCellTableViewCell.nib(), forCellReuseIdentifier: MyCellTableViewCell.identifier)
        tableView.register(QuickReplyTableViewCell.nib(), forCellReuseIdentifier: QuickReplyTableViewCell.identifier)
        view.addSubview(tableView)
        
        //MARK: - IsNetworkAvailable
        if  network.isNetworkAvailable(){
            apiManager.post(endpoint: "/tokens/generate") { (token) in
                self.apiManager.post(endpoint: "/conversations", token: token){ (streamURL) in
                    AlternativeViewController.streamURLVal = streamURL
                    self.webSocketCall()
                }
            }
            self.receive(self)
        } else{
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//MARK: - UITableViewDataSource
extension  AlternativeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HomeViewController.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = HomeViewController.messages[indexPath.row]
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)
        switch message.kind {
        case .text:
            let cellA = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
           cellA.configure(with: message)
            cellA.senderMessageBuble.frame.size = CGSize(width: screenWidth.width/2, height: 40)
            if(!isFromCurrentSender(message: message )){
                cellA.senderMessageBuble.backgroundColor = .brown
                cellA.senderMessageLabel.backgroundColor = .brown
                cellA.receiverLabel?.text = ""
                cellA.senderLabel?.text = message.sender.displayName
                cellA.receiverMessageLabel.text = ""
                cellA.receiverMessageBuble.backgroundColor = .none
            }else{
                cellA.receiverMessageBuble.backgroundColor = .gray
                cellA.senderMessageLabel.text = ""
                cellA.senderMessageBuble.backgroundColor = .none
                cellA.senderMessageLabel.backgroundColor = .none
                cellA.senderLabel?.text = ""
                cellA.receiverLabel?.text = message.sender.displayName
            }
            return cellA
        case .custom(let value):
            if value as! String == "attachments" {
                guard let cellB = tableView.dequeueReusableCell(withIdentifier: MyCellTableViewCell.identifier, for: indexPath) as? MyCellTableViewCell else{
                    fatalError()
                }
                cellB.configure(with: attachments)
                return cellB
            }
            if value as! String == "actions" {
                if indexPath.row == intTotalrow-1{
                    guard let cellB = tableView.dequeueReusableCell(withIdentifier: QuickReplyTableViewCell.identifier, for: indexPath) as? QuickReplyTableViewCell else{
                        fatalError()
                    }
                    cellB.delegate = self
                    cellB.configure(with: actions)
                    return cellB
                }
            }
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}


extension AlternativeViewController: AlternativeViewControllerDelegate{
    func webSocketCallAgain() {
        webSocketTask?.resume()
    }
    
    func webSocketCall()
        {
        url = URL(string: AlternativeViewController.streamURLVal)
        session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
        webSocketTask = session?.webSocketTask(with: url!)
        webSocketTask?.resume()
        }
    
    //MARK: - InsertMessage
     func insertNewMessage(_ message: Message) {
        HomeViewController.messages.append(message)
        tableView.reloadData()
    }
       
    //MARK: Receive
    func receive(_ controller: AlternativeViewController) {
        let workItem = DispatchWorkItem{ [weak self] in
            self?.webSocketTask?.receive(completionHandler: { [weak self] result in
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
                                    if (destructuredMessages[0].text != nil){
                                        self?.insertNewMessage(Message(sender: Sender(senderId: (destructuredMessages[0].from?.id)!, displayName: (destructuredMessages[0].from?.name)!), messageId: destructuredMessages[0].id!, kind:MessageKind.text(destructuredMessages[0].text!), sentDate: Date(), sectionCount: 1))
                                    }
                                    
                                    if((destructuredMessages[0].suggestedActions) != nil){
                                        if let actions = destructuredMessages[0].suggestedActions?.actions{
                                            self?.actions = actions
                                        }
                                        self?.insertNewMessage(Message(sender: Sender(senderId: (destructuredMessages[0].from?.id)!, displayName: (destructuredMessages[0].from?.name)!), messageId: destructuredMessages[0].id!, kind: MessageKind.custom("actions"), sentDate:Date(), sectionCount: destructuredMessages[0].attachments?.count))
                                    }
                                    
                                    if (destructuredMessages[0].attachments != nil) && destructuredMessages[0].attachments!.count > 0 {
                                        if let data = destructuredMessages[0].attachments{
                                            self?.attachments = data
                                        }
                                        self?.insertNewMessage(Message(sender: Sender(senderId: (destructuredMessages[0].from?.id)!, displayName: (destructuredMessages[0].from?.name)!), messageId: destructuredMessages[0].id!, kind: MessageKind.custom("attachments"), sentDate:Date(), sectionCount: destructuredMessages[0].attachments?.count))
                                        }
                                    
                                    let indexPath = IndexPath(row: ((HomeViewController.messages.count)) - 1, section: 0)
                                    self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
                self?.receive(self!)
            })
        }
        
    DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
}
