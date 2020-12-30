//
//  CodeVaultApp.swift
//  CodeVault
//
//  Created by William McGreaham on 12/30/20.
//

import SwiftUI

@main
struct CodeVaultApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
