//
//  DEmo2App.swift
//  DEmo2
//
//  Created by rajnikanthole on 12/08/25.
//

import SwiftUI

@main
struct DEmo2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
