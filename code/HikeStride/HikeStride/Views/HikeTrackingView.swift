//
//  HikeTrackingView.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-10.
//

import SwiftUI

struct HikeTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var healthManager: HealthManager
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var destination: HikingDestination
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showingHealthData = false
    @State private var stepCount: Double = 0
    @State private var activeCalories: Double = 0
    @State private var walkingDistance: Double = 0
    @State private var averageSpeed: Double = 0
    @State private var hikeStarted = false
    @State private var hikeStopped = false
    @State private var showingStopConfirmation = false
    
    
    var body: some View {
            VStack {
                if destination.isFinished {
                    VStack {
                        Text("Activity Summary")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Duration: ")
                                Text(formatTimeString(destination.totalTime ?? "00:00:00"))
                            }
                            HStack {
                                Text("Start Time: ")
                                Text("\(convertDateString(destination.startTime ?? Date()))")
                            }
                            HStack {
                                Text("End Time: ")
                                Text("\(convertDateString(destination.endTime ?? Date()))")
                            }
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(width: 300)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom)
 
                    }

                } else {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 18))
                        Text("Time")
                    }
                    .font(.title)
                    .fontWeight(.bold)
                    
                    Text("\(formatTime(elapsedTime))")
                        .font(.largeTitle)
                        .padding(.top, 1)
                        .fontWeight(.heavy)
                }

                Spacer()
                
                VStack {
                    Text("Your Activity")
                        .font(.title)
                        .fontWeight(.bold)
                    VStack {
                        HStack(spacing: 10) {
                            HealthCardView(title: "Steps", value: String(format: "%.1f", destination.isFinished ? destination.steps : stepCount), image: "shoeprints.fill", iconColor: .orange)
                                .previewLayout(.sizeThatFits)
                            HealthCardView(title: "Calories", value: String(format: "%.1f kcal", destination.isFinished ? destination.calories : activeCalories), image: "flame.fill", iconColor: .red)
                                .previewLayout(.sizeThatFits)
                        }
                        
                        HStack(spacing: 10) {
                            HealthCardView(title: "Distance", value: String(format: "%.1f m", destination.isFinished ? destination.distance : walkingDistance), image: "map.fill", iconColor: .brown)
                                .previewLayout(.sizeThatFits)
                            HealthCardView(title: "Avg Speed", value: String(format: "%.1f km/h", destination.isFinished ? destination.avgSpeed : averageSpeed), image: "figure.run", iconColor: .blue)
                                .previewLayout(.sizeThatFits)
                        }
                    }
                    .padding([.bottom, .leading, .trailing])
                }
                .padding([.top, .horizontal])
                
                Spacer()
                
                VStack(spacing: 10) {
                    if hikeStopped && destination.isFinished {
                        Button(action: saveContext) {
                            HStack {
                                Text("Save Activity")
                                Image(systemName: "figure.hiking")
                            }
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(.cyan)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    if !destination.isFinished {
                        Button(action: startHike) {
                            HStack {
                                Text(destination.startTime != nil ? "Resume Activity" : "Start Activity")
                                Image(systemName: "figure.hiking")
                            }
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(hikeStarted ? Color(UIColor.darkGray) : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(hikeStarted)
                        
                        HStack(spacing: 8) {
                            Button(action: pauseHike) {
                                HStack {
                                    Text("Pause")
                                    Image(systemName: "pause.fill")
                                }
                                .frame(maxWidth: .infinity, minHeight: 55)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showingStopConfirmation = true
                            }) {
                                HStack {
                                    Text("Stop")
                                    Image(systemName: "stop.fill")
                                }
                                .frame(maxWidth: .infinity, minHeight: 55)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .alert(isPresented: $showingStopConfirmation) {
                                Alert(
                                    title: Text("Confirm Stop"),
                                    message: Text("Are you sure you want to stop the hike?"),
                                    primaryButton: .destructive(Text("Stop")) {
                                        stopHike()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
       
    }
    
    private func startHike() {
        hikeStarted = true
        if destination.startTime == nil {
            destination.startTime = Date()
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func pauseHike() {
        print(destination)
        hikeStarted = false
        timer?.invalidate()
        fetchTodaysHealthData()
    }
    
    private func stopHike() {
        fetchTodaysHealthData()
        var formattedElapsedTime: String {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: elapsedTime) ?? "00:00:00"
        }
        hikeStarted = false
        hikeStopped = true
        timer?.invalidate()
        destination.endTime = Date()
        destination.isFinished = true
        destination.totalTime = formattedElapsedTime
        destination.steps = stepCount
        destination.avgSpeed = averageSpeed
        destination.calories = activeCalories
        destination.distance = walkingDistance
    }
    
//    private func fetchHealthData() {
//            guard let startTime = destination.startTime else { return }
//            let endTime = destination.endTime ?? Date()
//            
//            let group = DispatchGroup()
//            
//            group.enter()
//            healthManager.fetchTotalSteps(from: startTime, to: endTime) { result, error in
//                if let error = error {
//                    print("Error fetching steps: \(error)")
//                } else {
//                    stepCount = result
//                }
//                group.leave()
//            }
//            
//            group.enter()
//            healthManager.fetchTotalDistance(from: startTime, to: endTime) { result, error in
//                if let error = error {
//                    print("Error fetching distance: \(error)")
//                } else {
//                    walkingDistance = result
//                }
//                group.leave()
//            }
//            
//            group.enter()
//            healthManager.fetchActiveEnergyBurned(from: startTime, to: endTime) { result, error in
//                if let error = error {
//                    print("Error fetching active energy: \(error)")
//                } else {
//                    activeCalories = result
//                }
//                group.leave()
//            }
//            
//            group.notify(queue: .main) {
//                showingHealthData = true
//            }
//        }
    
    private func fetchTodaysHealthData() {
        healthManager.fetchTodaysHealthData { success, error in
            if success {
                stepCount = healthManager.steps
                walkingDistance = healthManager.distance
                activeCalories = healthManager.activeEnergy
                averageSpeed = healthManager.averageSpeed
                showingHealthData = true
            } else {
                print("Error fetching today's health data: \(String(describing: error))")
            }
        }
    }
    
    private func calculateWalkingSpeed() {
        guard let startTime = destination.startTime, let endTime = destination.endTime else { return }
        let duration = endTime.timeIntervalSince(startTime)
        if duration > 0 {
            averageSpeed = (walkingDistance / 1000) / (duration / 3600)
        } else {
            averageSpeed = 0
        }
    }
     
    private func saveContext() {
        destination.isFinished = true
        hikeStopped = false
        print(destination)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct HikeTrackingView_Previews: PreviewProvider {
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
        newDestination.steps = 10000
        newDestination.distance = 8000
        newDestination.calories = 500
       // newDestination.isFinished = true
        return HikeTrackingView(destination: newDestination).environment(\.managedObjectContext, viewContext)
    }
}
