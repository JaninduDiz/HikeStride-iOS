//
//  HikingDestinationDetailView.swift
//  Hiking Partner
//
//  Created by Janindu Dissanayake on 2024-06-09.
//

import SwiftUI
import MapKit

struct HikingDestinationDetailView: View {
    var destination: HikingDestination
    @State private var showingActionSheet = false
    @State private var selectedMapApp: MapApp?
    @State private var showingHikeTracking = false
    enum MapApp {
            case apple
            case google
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                MapViewWithRoute(latitude: destination.latitude, longitude: destination.longitude)
                    .frame(height: 400)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Address: \(destination.location ?? "Unknown")")
                    
                    Text("Difficulty Level: \(destination.difficulty)")
                    
                    Text("Type: \(destination.type ?? "Unknown")")
                    
                    Text(destination.info ?? "No description available.")
                    
                }
                .font(.headline)
                .padding()
                
                Spacer()
                
                NavigationLink(destination: HikeTrackingView(destination: destination)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)) {
                        Text(destination.isFinished ? "View Activity" : "Start the Hike")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding([.leading, .trailing])
                    }
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Text("Get Directions")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .bottom])
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Select Map for Open Directions"), buttons: [
                        .default(Text("Apple Maps")) {
                            selectedMapApp = .apple
                            openInMaps(destination: destination, mapApp: .apple)
                        },
                        .default(Text("Google Maps")) {
                            selectedMapApp = .google
                            openInMaps(destination: destination, mapApp: .google)
                        },
                        .cancel()
                    ])
                }
                
            }
        }
        .navigationTitle(destination.name ?? "Unknown")
    }
    
    private func openInMaps(destination: HikingDestination, mapApp: MapApp) {
        let latitude = destination.latitude
        let longitude = destination.longitude
        let urlAppleMaps = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let urlGoogleMaps = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let urlBrowser = "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving"
        
        switch mapApp {
        case .apple:
            if let url = URL(string: urlAppleMaps) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .google:
            if let url = URL(string: urlGoogleMaps), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: urlBrowser) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}


struct HikingDestinationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let newDestination = HikingDestination(context: viewContext)
        newDestination.name = "Test Trail"
        newDestination.location = "Test Location"
        newDestination.difficulty = 3
        newDestination.type = "Loop"
        newDestination.info = "A beautiful hiking trail."
        newDestination.latitude = 37.7749
        newDestination.longitude = -122.4194
        return HikingDestinationDetailView(destination: newDestination)
    }
}
