//
//  HikingDestinationListView.swift
//  Hiking Partner
//
//  Created by Janindu Dissanayake on 2024-06-09.
//

import SwiftUI
import CoreData

struct HikingDestinationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: HikingDestination.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HikingDestination.name, ascending: true)]
    ) 
    var destinations: FetchedResults<HikingDestination>
    @State private var showingAddDestination = false
    @State private var showCompletedOnly = false
    
        private var filteredDestinations: [HikingDestination] {
            if showCompletedOnly {
                return destinations.filter { $0.isFinished }
            } else {
                return Array(destinations)
            }
        }
    
    var body: some View {
        NavigationView {
            VStack {
                if destinations.isEmpty {
                    Button(action: {
                        showingAddDestination.toggle()
                    }) {
                        Label("Plan Your Hike", systemImage: "figure.hiking")
                    }
                } else {
                    List {
                        Toggle(isOn: $showCompletedOnly) {
                           Text("Completed Journeys")
                       }
                        ForEach(filteredDestinations) { destination in
                            NavigationLink(destination: HikingDestinationDetailView(destination: destination)) {
                                HStack {
                                    Image(systemName: "figure.hiking")
                                        .frame(width: 10)
                                        .font(.system(size: 20))
                                        .padding(.trailing)
                                        .foregroundStyle(.green)
                                    VStack(alignment: .leading) {
                                        Text(destination.name ?? "Unknown")
                                        Text(destination.location ?? "Unknown")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .frame(width: 150, alignment: .leading)
                                           .lineLimit(1)
                                           .truncationMode(.tail)
                                    }
                                    Spacer()
                                    if destination.isFinished {
                                        Image(systemName: "flag.fill")
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                .padding()
                            }
                        }
                        .onDelete(perform: deleteDestinations)
                    }
                    .animation(.default, value: filteredDestinations)
                }
            }
            .navigationTitle("Hiking Destinations")
            .toolbar {
                if !destinations.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddDestination.toggle()
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddDestination) {
                AddHikingDestinationView()
                    
            }
        }
    }
    
    private func deleteDestinations(offsets: IndexSet) {
        withAnimation {
            offsets.map { destinations[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct HikingDestinationListView_Previews: PreviewProvider {
    static var previews: some View {
        HikingDestinationListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
