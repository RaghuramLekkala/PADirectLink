//
//  ViewController.swift
//  IOSChatBot
//
//  Created by Raghuram on 24/05/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    let alert = UIAlertController(title: "Name is required", message: "Please enter a valid name", preferredStyle: .alert)
    var uuid = UUID().uuidString
    
    //MARK: - networking
    let network = Netwotking()
    let networkAlert = UIAlertController(title: "No internet detected", message: "Please connect to internet", preferredStyle: .alert)
    
   static var messages:[Message] = []
    
    let apiManager = ApiManager()
    func isValidInput(Input:String) -> Bool {
        let RegEx = "\\w{3,18}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if let name = nameTextField?.text{
            if isValidInput(Input: name){
                    self.performSegue(withIdentifier: K.alternateChatSegue, sender: self)
            }else{
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if let
            tokenValue = UserDefaults.standard.string(forKey: "token"){
            
            apiManager.post(endpoint: "/tokens/refresh", token: tokenValue) {
                DispatchQueue.main.async {
                    if let
                        uuidValue = UserDefaults.standard.string(forKey: "UUID"){
                        self.uuid = uuidValue
                    }
                    if let senderNameValue = UserDefaults.standard.string(forKey: "SENDERNAME"){
                        self.nameTextField.text = senderNameValue
                    }
                self.performSegue(withIdentifier: K.alternateChatSegue, sender: self)
                }
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UserDefaults.standard.set(nameTextField.text, forKey: "SENDERNAME")
        UserDefaults.standard.set(uuid, forKey: "UUID")
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.homeSegue{
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.senderNameValue = nameTextField.text
            destinationVC.uuid = uuid
        }
        if segue.identifier == K.alternateChatSegue{
            let destinationVC = segue.destination as! AlternativeViewController
            destinationVC.senderNameValue = nameTextField.text
            destinationVC.uuid = uuid
        }
    }
}
