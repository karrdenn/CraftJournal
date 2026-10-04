//
//  Zorig_Craft_JournalApp.swift
//  Zorig Craft Journal
//
//  Created by iMac08 on 9/29/26.
//

import SwiftUI
import CoreData

@main
struct Zorig_Craft_JournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
