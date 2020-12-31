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
        ZStack{
            NavigationView{
                List {
                    ForEach(items) { item in
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    }
                    .onDelete(perform: deleteItems)
                    .onTapGesture {
                        print("Tapped")
                    }
                }//List
                .navigationTitle("Websites")
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }//NavigationView
            
            
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        addItem()
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
            }
        }
        
    }

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
        
        withAnimation {
            let newEntry = LoginEntry(context: viewContext)
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
