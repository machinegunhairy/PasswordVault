//
//  LoginDataModel.swift
//  CodeVault
//
//  Created by William McGreaham on 12/30/20.
//

import Combine
import Foundation
import CryptoKit

class LoginDataModel: ObservableObject {
    static let shared = LoginDataModel()
    
    @Published var isLoggedIn: Bool = false
    
    func login(username: String, password: String) -> Bool {
        let passwordData = Data(password.utf8)
        let hashedPassword = SHA512.hash(data: passwordData)
        if (hashedPassword.description == getFromDefaults(key: username)) {
            self.isLoggedIn = true
            return true
        }
        return false
    }
    
    func create(username: String, password: String) -> Bool {
        guard getFromDefaults(key: username) == nil else {
            return false
        }
        
        let passwordData = Data(password.utf8)
        let hashedPassword = SHA512.hash(data: passwordData)
//        print(hashedPassword)
        setToDefaults(key: username, theValue: hashedPassword)
        _ = login(username: username, password: password)
        return true
    }
    
    func logout() {
        self.isLoggedIn = false
    }
    
    private func getFromDefaults(key: String) -> String? {
        let def = UserDefaults.standard
        guard let theValue = def.object(forKey: key) as? String else {
            return nil
        }
        
        return theValue
    }
    
    private func setToDefaults(key: String, theValue: SHA512Digest) {
        let def = UserDefaults.standard
        def.set(theValue.description, forKey: key)
    }
}
