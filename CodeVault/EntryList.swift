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
    @State private var webImage: Image?
    var body: some View {
        HStack {
            webImage?
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(loginObject.websiteURL)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text(loginObject.loginName)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text(loginObject.loginPassword)
                    .frame(maxWidth:.infinity, alignment: .leading)
            } //VStack
        } //HStack
        .cornerRadius(10.0)
        .onAppear(perform: loadImage)
    } //View
    
    func loadImage() {
        webImage = Image(ImageGrabber.getImage(siteName: loginObject.websiteURL))
    }
}

struct EntryList: View {
    private var loggedInName: String
    var websiteDetails: FetchRequest<LoginEntry>
    @State private var showingCustomAdditonPopup = false
    @State private var newWebsite:String = ""
    @State private var newUsername:String = ""
    @State private var newPassword:String = ""
    
    @State private var popupTitle:String = ""
    @State private var popupSaveButtonTitle:String = ""
    @State private var isUpdatingRow:Bool = false
    @State private var selectedRow:FetchedResults<LoginEntry>.Element? = nil
    
    @Environment(\.managedObjectContext) private var viewContext

    init(_ loggedIn: String) {
        loggedInName = loggedIn
        websiteDetails = FetchRequest<LoginEntry>(
            entity: LoginEntry.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \LoginEntry.website, ascending: true)],
            predicate: NSPredicate(format: "appLoginName == %@",loggedIn))
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                List {
                    ForEach(websiteDetails.wrappedValue, id: \.self) { webEntry in
                        let website: String = webEntry.website ?? "Error"
                        let logName: String = webEntry.username ?? "Error"
                        let logPassword: String = webEntry.password ?? "Error"
                        let encryptedPassword = try? KeychainInterface.readPassword(account: logPassword)
                        LoginRow(loginObject: LoginEntryObject(id: UUID(),
                                                               websiteURL: website,
                                                               loginName: logName,
                                                               loginPassword: encryptedPassword ?? "Password Failed"))
                            .contentShape(Rectangle())
                            //                            .foregroundColor(Color.yellow) //text color
                            .onTapGesture {
                                setPopupForUpdate()
                                selectedRow = webEntry
                                self.newWebsite = website
                                self.newUsername = logName
                                self.newPassword = encryptedPassword ?? "Password Error"
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
                        .background(Color(UIColor.systemBlue))
                        .cornerRadius(100)
                    }
                    .padding(.trailing, 30)
                }//Vstack, bottom-right button
                
                if $showingCustomAdditonPopup.wrappedValue {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack { //Here to position the popup at the top
                            VStack(spacing: 20) {
                                Text(popupTitle)
                                    .bold().padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.systemBlue))
                                    .foregroundColor(Color.white)
                                Group {
                                    TextField("Website Name", text: $newWebsite)
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
                                HStack { //Buttons
                                    Button(action: {
                                        self.showingCustomAdditonPopup = false
                                        clearPopupValues()
                                    }) {
                                        Text("Close")
                                    }
                                    .padding()
                                    .background(Color(UIColor.systemBlue))
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
                                    .background(Color(UIColor.systemBlue))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                }//HStack
                                .padding(12)
                            }//VStack
                            .frame(width: 300, height: 336, alignment: .top)
                            
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20).shadow(radius: 20)
                            .padding(.vertical)
                            Spacer()
                        }//Outer VStack
                        
                    }//ZStack
                }//Popup Wrapper
                
            }//ZStack
            .navigationTitle("Websites")
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }//NavigationView
        
    }//Body
    
    private func addWebsite() {
        withAnimation {
            let newEntry = LoginEntry(context: viewContext)
            newEntry.appLoginName = self.loggedInName
            newEntry.website = self.newWebsite
            newEntry.username = self.newUsername
            newEntry.password = self.newWebsite + self.newUsername
            
            do {
                try viewContext.save()
                try? KeychainInterface.save(passwordString: self.newPassword,
                                            account: newEntry.password ?? "ErrorState")
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
            selectedRow?.password = self.newWebsite + self.newUsername
            try? viewContext.save()
            try? KeychainInterface.update(passwordString: self.newPassword, account: selectedRow?.password ?? "ErrorState")
        }
    }
    
    private func deleteLoginEntry(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let entry = websiteDetails.wrappedValue[index]
                try? KeychainInterface.deletePassword(account: entry.password ?? "ErrorState")
                viewContext.delete(entry)
            }

            do {
                try viewContext.save()
            } catch {
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
