//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-04-24.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
