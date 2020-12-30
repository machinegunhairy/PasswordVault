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
    
    func login(username: String, password: String) {
        let passwordData = Data(password.utf8)
        let hashedPassword = SHA512.hash(data: passwordData)
        print(hashedPassword) //compared against stored
        self.isLoggedIn = true
    }
    
    func create(username: String, password: String) -> Bool {
        var userExists = true
        if userExists {
            return false
        }
        //check if user exists, login if so
        
        let passwordData = Data(password.utf8)
        let hashedPassword = SHA512.hash(data: passwordData)
        print(hashedPassword) //make new entry
        login(username: username, password: password)
        return true
    }
    
    func logout() {
        self.isLoggedIn = false
    }
}
