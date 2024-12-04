//
//  MapView.swift
//  Hiking Partner
//
//  Created by Janindu Dissanayake on 2024-06-09.
//

import SwiftUI
import MapKit

struct MapViewWithSelector: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var address: String?

    let locationManager = CLLocationManager()

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
        var parent: MapViewWithSelector
        var hasCenteredOnUserLocation = false

        init(parent: MapViewWithSelector) {
            self.parent = parent
            super.init()
            self.parent.locationManager.delegate = self
            self.parent.locationManager.requestWhenInUseAuthorization()
            self.parent.locationManager.startUpdatingLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }
            if !hasCenteredOnUserLocation {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                parent.mapView.setRegion(region, animated: true)
                hasCenteredOnUserLocation = true
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.canShowCallout = true
            annotationView.animatesWhenAdded = true
            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let coordinate = view.annotation?.coordinate else { return }
            parent.selectedLocation = coordinate
            parent.getAddress(from: coordinate)
        }

        @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.addAnnotation(annotation)
            parent.selectedLocation = coordinate
            parent.getAddress(from: coordinate)
        }
        
        // UISearchBarDelegate method
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let query = searchBar.text, !query.isEmpty else { return }
            searchBar.resignFirstResponder()
            performSearch(query: query)
        }

        func performSearch(query: String) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = parent.mapView.region

            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let annotations = response.mapItems.map { item -> MKPointAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    return annotation
                }
                self.parent.mapView.removeAnnotations(self.parent.mapView.annotations)
                self.parent.mapView.addAnnotations(annotations)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    let mapView = MKMapView()

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)

        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search for places"
        
        containerView.addSubview(mapView)
        containerView.addSubview(searchBar)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func getAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                self.address = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
}
