//
//  extensions.swift
//  IOSChatBot
//
//  Created by Raghuram on 25/05/22.
//

import Foundation
import UIKit

extension UIViewController {
    func loader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait..", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame:  CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.style = .large
        alert.view.addSubview(indicator)
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func dismissLoader(loader: UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
}

extension UserDefaults {
  func setCodable<T: Codable>(_ value: T, forKey key: String) {
    guard let data = try? JSONEncoder().encode(value) else {
      fatalError("Cannot create a json representation of \(value)")
    }
    self.set(data, forKey: key)
  }

  func codable<T: Codable>(forKey key: String) -> T? {
    guard let data = self.data(forKey: key) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: data)
  }
}
