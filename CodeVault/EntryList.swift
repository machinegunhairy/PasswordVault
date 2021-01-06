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
            Text(loginObject.websiteURL)
        }
    }
}

struct EntryList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: LoginEntry.entity(),
        sortDescriptors: []//, predicate: NSPredicate(format: "website == %@", "www.aol.com")
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
                            addWebsite()
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
                }//Vstack
                
            }//ZStack
            .navigationTitle("Websites") //mcgreahamtodo
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }//NavigationView
        
    }//Body
    
    private func addWebsite() {
        let _name = "myUsername"
        let _site = "website.com"
        let _password = "password"
        let _loginName = "nameILoggedIntoThisAppWith"
        
        withAnimation {
            let newEntry = LoginEntry(context: viewContext)
            newEntry.appLoginName = _loginName
            newEntry.website = _site
            newEntry.username = _name
            newEntry.password = _password
            
            do {
                try viewContext.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }

    private func deleteLoginEntry(offsets: IndexSet) {
        print(websiteDetails)
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
}
/*
struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
