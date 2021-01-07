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
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text(loginObject.loginName)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text(loginObject.loginPassword)
                    .frame(maxWidth:.infinity, alignment: .leading)
            } //VStack
            .padding()
        } //HStack
    } //View
}

struct EntryList: View {
    @State private var showingCustomAdditonPopup = false
    @State private var newWebsite:String = ""
    @State private var newUsername:String = ""
    @State private var newPassword:String = ""
    
    @State private var popupTitle:String = ""
    @State private var popupSaveButtonTitle:String = ""
    @State private var isUpdatingRow:Bool = false
    @State private var selectedRow:FetchedResults<LoginEntry>.Element? = nil
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: LoginEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \LoginEntry.website, ascending: true)]
    ) private var websiteDetails: FetchedResults<LoginEntry>
    
    var body: some View {
        NavigationView{
            ZStack{
                List {
                    ForEach(websiteDetails) { webEntry in
                        let website = webEntry.website ?? "Error"
                        let logName = webEntry.username ?? "Error"
                        let logPassword = webEntry.password ?? "Error"
                        LoginRow(loginObject: LoginEntryObject(id: UUID(),
                                                               websiteURL: website,
                                                               loginName: logName,
                                                               loginPassword: logPassword))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                setPopupForUpdate()
                                selectedRow = webEntry
                                self.newWebsite = website
                                self.newUsername = logName
                                self.newPassword = logPassword
                                showingCustomAdditonPopup = true
                            }
                    }
                    .onDelete(perform: deleteLoginEntry)
                }//List
                
                //This is for the bottom-right button
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            setPopupForNewEntry()
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
                            Text(popupTitle)
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
                                    clearPopupValues()
                                }) {
                                    Text("Close")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    if !self.newWebsite.isEmpty && !self.newUsername.isEmpty && !self.newPassword.isEmpty {
                                        if isUpdatingRow {
                                            updateWebsite()
                                        } else {
                                            addWebsite()
                                        }
                                        self.showingCustomAdditonPopup = false
                                    }
                                }) {
                                    Text(popupSaveButtonTitle)
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                            }//HStack
                            .padding(12)
                        }//VStack
                        .frame(width: 300, height: 336)
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
                clearPopupValues()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    private func updateWebsite() {
        viewContext.performAndWait {
            selectedRow?.website = self.newWebsite
            selectedRow?.username = self.newUsername
            selectedRow?.password = self.newPassword
            try? viewContext.save()
        }
    }

    private func deleteLoginEntry(offsets: IndexSet) {
        withAnimation {
            offsets.map { websiteDetails[$0] }.forEach(viewContext.delete)

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
    
    private func clearPopupValues() {
        newPassword = ""
        newUsername = ""
        newWebsite = ""
    }
    
    private func setPopupForNewEntry() {
        popupTitle = "Add New Entry"
        popupSaveButtonTitle = "Save"
        isUpdatingRow = false
    }
    
    private func setPopupForUpdate() {
        popupTitle = "Update Information"
        popupSaveButtonTitle = "Update"
        isUpdatingRow = true
    }
}
/*
struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
