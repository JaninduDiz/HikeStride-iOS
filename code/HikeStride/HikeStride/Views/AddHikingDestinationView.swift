//
//  AddHikingDestinationView.swift
//  Hiking Partner
//
//  Created by Janindu Dissanayake on 2024-06-09.
//

import SwiftUI
import MapKit

struct AddHikingDestinationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var difficulty: Double = 1
    @State private var type: String = ""
    @State private var info: String = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationAddress: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destination Details")) {
                    TextField("Name", text: $name)
                   
                    Picker("Type", selection: $type) {
                            Text("Loop").tag("Loop")
                            Text("Out-and-Back").tag("Out-and-Back")
                            Text("Backpacking").tag("Backpacking")
                            Text("Base camping").tag("Base-Camping")
                            Text("Section hiking").tag("Section-hiking")
                        }
                    
                        .cornerRadius(5)
                    
                    Slider(
                        value: $difficulty,
                        in: 1...10, step: 1,
                        minimumValueLabel: Text("Difficulty"),
                        maximumValueLabel: Text("\(Int(difficulty))/10"),
                        label: {
                            Text("Difficulty Level")
                        }
                    )
                }

                Section(header: Text("Select Location")) {
                    TextField("Location", text: Binding(
                        get: { locationAddress ?? "" },
                        set: { locationAddress = $0 }
                    ))
                    .disabled(true)
                    
                    MapViewWithSelector(selectedLocation: $selectedLocation, address: $locationAddress)
                        .frame(height: 400)
                }
                
                Section(header: Text("Description or Notes")) {
                    TextEditor(text: $info)
                        .frame(height: 100)
                        .background(Color(UIColor.secondarySystemBackground))
                }
                
            }
            .navigationTitle("Add Destination")
            .navigationBarItems(trailing: Button(action: saveDestination) {
                Text("Save")
            })
            .navigationBarItems(leading: Button(action: closeSheet) {
                Text("Cancel")
            })
        }
        
    }
    
    private func closeSheet() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveDestination() {
        guard let selectedLocation = selectedLocation, let locationAddress = locationAddress else { return }
        
        let newDestination = HikingDestination(context: viewContext)
        newDestination.name = name
        newDestination.location = locationAddress
        newDestination.latitude = selectedLocation.latitude
        newDestination.longitude = selectedLocation.longitude
        newDestination.difficulty = Int16(difficulty)
        newDestination.type = type
        newDestination.info = info
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddHikingDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        AddHikingDestinationView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
