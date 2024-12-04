//
//  HikeStrideApp.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-07.
//

import SwiftUI

@main
struct HikeStrideApp: App {
    let persistenceController = PersistenceController.shared
    let healthManager = HealthManager.shared  // Add HealthManager

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(healthManager)  // Pass HealthManager to the environment
        }
    }
}
