//
//  ContentView.swift
//  CodeVault
//
//  Created by William McGreaham on 12/30/20.
//

import SwiftUI
import CoreData

struct AlertData: Identifiable {
    var id = UUID()
    var title: String
    var message: String
}

struct ContentView: View {
    @State private var userName = ""
    @State private var password = ""
    @State private var alertData: AlertData? = nil
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var loginModel: LoginDataModel = .shared
    
    var body: some View {
        if loginModel.isLoggedIn {
            EntryList(userName)
        } else {
            
            ZStack{
                Color.init(red: 12.0/255.0,
                           green: 50.0/255.0,
                           blue: 100.0/255.0)
                    .ignoresSafeArea()
                
                GroupBox {
                    Text("Password Vault")
                    
                    TextField("Username", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    HStack{
                        Button(action: {
                            createPressed()
                        }) {
                            Text("Create")
                                .padding(EdgeInsets(top: 6,
                                                    leading: 18,
                                                    bottom: 6,
                                                    trailing: 18))
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        } //Create Button
                        
                        Button(action: {
                            loginPressed()
                        }) {
                            Text("Login")
                                .padding(EdgeInsets(top: 6,
                                                    leading: 18,
                                                    bottom: 6,
                                                    trailing: 18))
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        } //Login Button
                    } //Hstack
                    
                } //GroupBox
                .padding()
                .alert(item: $alertData) { alertButtonData in
                    Alert(title: Text(alertButtonData.title),
                          message: Text(alertButtonData.message),
                          dismissButton: .default(Text("Ok"), action: {
                            self.alertData = nil
                          }))
                }
            } //ZStack
        }
    }
    
    private func loginPressed() {
        if !loginModel.login(username: userName, password: password) {
            self.alertData = AlertData(title: "Please try again",
                                       message: "This username/password combination is not found. Username and password are case sensitive, please try again.")
        } else {
            password = ""
        }
    }
    
    private func createPressed() {
        if !loginModel.create(username: userName, password: password) {
            self.alertData = AlertData(title: "User Exists",
                                       message: "This user already exists. Please pick a unique username.")
        } else {
            password = ""
        }
    }
    
    
} // Struct Content View

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
