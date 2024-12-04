//
//  ContentView.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-07.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var healthManager: HealthManager
    
    @State private var healthKitAuthorized = false
    
    var body: some View {
        HikingDestinationListView()
            .environmentObject(healthManager)
            .environment(\.managedObjectContext, viewContext)
            .onAppear(perform: requestHealthKitAuthorization)
    }
    
    private func requestHealthKitAuthorization() {
        healthManager.requestAuthorization { success, error in
            if success {
                healthKitAuthorized = true
            } else {
                // Handle error
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return ContentView()
            .environmentObject(HealthManager.shared)
            .environment(\.managedObjectContext, context)
    }
}
