//
//  EntryList.swift
//  CodeVault
//
//  Created by William McGreaham on 12/30/20.
//

import SwiftUI

struct EntryList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>

    @FetchRequest(
        entity: LoginEntry.entity(),
        sortDescriptors: []//, predicate: NSPredicate(format: "website == %@", "www.aol.com")
    ) private var websiteDetails: FetchedResults<LoginEntry>
    
    var body: some View {
        NavigationView{
            
            ZStack{
                
                List {
                    ForEach(items) { item in
                        Label {
                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                                .padding()
                            } icon: {
                                Image("blizzardIcon")
                            }
                    }
                    
                    .onDelete(perform: deleteItems)
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
                            addItem()
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

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        print(websiteDetails)
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
