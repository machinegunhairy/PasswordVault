//
//  EntryList.swift
//  CodeVault
//
//  Created by William McGreaham on 12/30/20.
//

import SwiftUI

struct LoginEntryObject: Identifiable {
    var id = UUID()
    var websiteURL: String
    var loginName: String
    var loginPassword: String
}

struct LoginRow: View {
    var loginObject: LoginEntryObject
    
    var body: some View {
        HStack {
            Image("blizzardIcon")
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(loginObject.websiteURL)
                Text(loginObject.loginName)
                Text(loginObject.loginPassword)
            } //VStack
        } //HStack
    } //View
}

struct EntryList: View {
    @State private var showingCustomAdditonPopup = false
    @State private var newWebsite:String = ""
    @State private var newUsername:String = ""
    @State private var newPassword:String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: LoginEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \LoginEntry.website, ascending: true)]//, predicate: NSPredicate(format: "website == %@", "www.aol.com")
    ) private var websiteDetails: FetchedResults<LoginEntry>
    
    var body: some View {
        NavigationView{
            ZStack{
                List {
                    ForEach(websiteDetails) { webEntry in
                        LoginRow(loginObject: LoginEntryObject(id: UUID(),
                                                               websiteURL: webEntry.website ?? "Error",
                                                               loginName: webEntry.username ?? "Error",
                                                               loginPassword: webEntry.password ?? "Error"))
                    }
                    .onDelete(perform: deleteLoginEntry)
                    .onTapGesture {
                        print("Tapped")
                    }
                }//List
                
                //This is for the bottom-right button
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            self.showingCustomAdditonPopup = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                        }
                        .padding(20)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(100)
                    }
                    .padding(.trailing, 30)
                }//Vstack, bottom-right button
                if $showingCustomAdditonPopup.wrappedValue {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("New Login Information")
                                .bold().padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                            Group {
                                TextField("www.", text: $newWebsite)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                TextField("Username", text: $newUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                TextField("Password", text: $newPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            HStack {
                                Button(action: {
                                    self.showingCustomAdditonPopup = false
                                }) {
                                    Text("Close")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    if !self.newWebsite.isEmpty && !self.newUsername.isEmpty && !self.newPassword.isEmpty {
                                        addWebsite()
                                        self.showingCustomAdditonPopup = false
                                    }
                                }) {
                                    Text("Save")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                            }//HStack
                            .padding(12)
                        }//VStack
                        .frame(width: 300, height: 325)
                        .background(Color.white)
                        .cornerRadius(20).shadow(radius: 20)
                    }//ZStack
                }//Popup Wrapper
            }//ZStack
            .navigationTitle("Websites") //mcgreahamtodo
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }//NavigationView
        
    }//Body
    
    private func addWebsite() {
        let _loginName = "nameILoggedIntoThisAppWith"
        
        withAnimation {
            let newEntry = LoginEntry(context: viewContext)
            newEntry.appLoginName = _loginName
            newEntry.website = self.newWebsite
            newEntry.username = self.newUsername
            newEntry.password = self.newPassword
            
            do {
                try viewContext.save()
                self.newWebsite = ""
                self.newUsername = ""
                self.newPassword = ""
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }

    private func deleteLoginEntry(offsets: IndexSet) {
        withAnimation {
            offsets.map { websiteDetails[$0] }.forEach(viewContext.delete)
//            viewContext.delete(<#T##object: NSManagedObject##NSManagedObject#>)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
/*
struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
