//
//  HealthManager.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-08.
//

import Foundation
import HealthKit
import Combine

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()
    
    @Published var steps: Double = 0.0
    @Published var distance: Double = 0.0
    @Published var activeEnergy: Double = 0.0
    @Published var averageSpeed: Double = 0.0

    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let healthDataToRead = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])

        healthStore.requestAuthorization(toShare: nil, read: healthDataToRead) { (success, error) in
            completion(success, error)
        }
    }

    // Fetch the total steps for a given time period
    func fetchTotalSteps(from startDate: Date, to endDate: Date, completion: @escaping (Double, Error?) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error)
                return
            }
            DispatchQueue.main.async {
                self.steps = sum.doubleValue(for: HKUnit.count())
            }
            completion(sum.doubleValue(for: HKUnit.count()), nil)
        }

        healthStore.execute(query)
    }

    // Fetch the total distance for a given time period
    func fetchTotalDistance(from startDate: Date, to endDate: Date, completion: @escaping (Double, Error?) -> Void) {
        let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error)
                return
            }
            DispatchQueue.main.async {
                self.distance = sum.doubleValue(for: HKUnit.meter())
            }
            completion(sum.doubleValue(for: HKUnit.meter()), nil)
        }

        healthStore.execute(query)
    }

    // Fetch the active energy burned for a given time period
    func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date, completion: @escaping (Double, Error?) -> Void) {
        let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error)
                return
            }
            DispatchQueue.main.async {
                self.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
            }
            completion(sum.doubleValue(for: HKUnit.kilocalorie()), nil)
        }

        healthStore.execute(query)
    }

    // Fetch today's health data
    func fetchTodaysHealthData(completion: @escaping (Bool, Error?) -> Void) {
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let group = DispatchGroup()
        
        var fetchError: Error?
        
        group.enter()
        fetchTotalSteps(from: startDate, to: endDate) { result, error in
            if let error = error {
                fetchError = error
            }
            group.leave()
        }
        
        group.enter()
        fetchTotalDistance(from: startDate, to: endDate) { result, error in
            if let error = error {
                fetchError = error
            }
            group.leave()
        }
        
        group.enter()
        fetchActiveEnergyBurned(from: startDate, to: endDate) { result, error in
            if let error = error {
                fetchError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(false, error)
            } else {
                self.calculateAverageSpeed(from: startDate, to: endDate)
                completion(true, nil)
            }
        }
    }

    // Calculate average speed for a given time period
    private func calculateAverageSpeed(from startDate: Date, to endDate: Date) {
        let timeInterval = endDate.timeIntervalSince(startDate) // Time in seconds
        let timeInHours = timeInterval / 3600.0 // Convert time to hours

        if timeInHours > 0 {
            self.averageSpeed = self.distance / timeInHours // Speed in meters per hour
        } else {
            self.averageSpeed = 0.0
        }
    }
}


//import HealthKit
//import SwiftUI
//
//class HealthKitManager: ObservableObject {
//    static let shared = HealthKitManager()
//    let healthStore = HKHealthStore()
//    
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            completion(false)
//            return
//        }
//        
//        let healthKitTypes: Set = [
//            HKObjectType.quantityType(forIdentifier: .stepCount)!,
//            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
//        ]
//        
//        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { success, error in
//            if let error = error {
//                print("HealthKit Authorization Error: \(error.localizedDescription)")
//            }
//            DispatchQueue.main.async {
//                completion(success)
//            }
//        }
//    }
//    
//    func getStepCount(start: Date, end: Date, completion: @escaping (Double) -> Void) {
//        guard let sampleType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
//            print("Step Count sample type not available.")
//            completion(0)
//            return
//        }
//        fetchSumQuantity(sampleType: sampleType, unit: HKUnit.count(), start: start, end: end, completion: completion)
//    }
//    
//    func getWalkingDistance(start: Date, end: Date, completion: @escaping (Double) -> Void) {
//        guard let sampleType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
//            print("Distance Walking Running sample type not available.")
//            completion(0)
//            return
//        }
//        fetchSumQuantity(sampleType: sampleType, unit: HKUnit.meter(), start: start, end: end, completion: completion)
//    }
//    
//    func getActiveCalories(start: Date, end: Date, completion: @escaping (Double) -> Void) {
//        guard let sampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            print("Active Energy Burned sample type not available.")
//            completion(0)
//            return
//        }
//        fetchSumQuantity(sampleType: sampleType, unit: HKUnit.kilocalorie(), start: start, end: end, completion: completion)
//    }
//    
//    private func fetchSumQuantity(sampleType: HKSampleType, unit: HKUnit, start: Date, end: Date, completion: @escaping (Double) -> Void) {
//        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
//        let query = HKStatisticsQuery(quantityType: sampleType as! HKQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
//            if let error = error {
//                print("Error fetching \(sampleType.identifier) data: \(error.localizedDescription)")
//                completion(0)
//                return
//            }
//            guard let result = result, let sum = result.sumQuantity() else {
//                print("No data available for \(sampleType.identifier)")
//                completion(0)
//                return
//            }
//            completion(sum.doubleValue(for: unit))
//        }
//        healthStore.execute(query)
//    }
//}



//import Foundation
//import HealthKit
//import Combine
//
//class HealthManager: ObservableObject {
//    static let shared = HealthManager()
//    private let healthStore = HKHealthStore()
//    
//    @Published var steps: Double = 0.0
//    @Published var distance: Double = 0.0
//    @Published var activeEnergy: Double = 0.0
//
//    // Request authorization to access HealthKit data
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        let healthDataToRead = Set([
//            HKObjectType.quantityType(forIdentifier: .stepCount)!,
//            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
//        ])
//
//        healthStore.requestAuthorization(toShare: nil, read: healthDataToRead) { (success, error) in
//            completion(success, error)
//        }
//    }
//
//    // Fetch the total steps for a given day
//    func fetchTotalSteps(for date: Date, completion: @escaping (Double, Error?) -> Void) {
//        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: date), end: Calendar.current.startOfDay(for: date).addingTimeInterval(86400), options: .strictStartDate)
//        
//        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
//            guard let result = result, let sum = result.sumQuantity() else {
//                completion(0.0, error)
//                return
//            }
//            DispatchQueue.main.async {
//                self.steps = sum.doubleValue(for: HKUnit.count())
//            }
//            completion(sum.doubleValue(for: HKUnit.count()), nil)
//        }
//
//        healthStore.execute(query)
//    }
//
//    // Fetch the total distance for a given day
//    func fetchTotalDistance(for date: Date, completion: @escaping (Double, Error?) -> Void) {
//        let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: date), end: Calendar.current.startOfDay(for: date).addingTimeInterval(86400), options: .strictStartDate)
//        
//        let query = HKStatisticsQuery(quantityType: distanceQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
//            guard let result = result, let sum = result.sumQuantity() else {
//                completion(0.0, error)
//                return
//            }
//            DispatchQueue.main.async {
//                self.distance = sum.doubleValue(for: HKUnit.meter())
//            }
//            completion(sum.doubleValue(for: HKUnit.meter()), nil)
//        }
//
//        healthStore.execute(query)
//    }
//
//    // Fetch the active energy burned for a given day
//    func fetchActiveEnergyBurned(for date: Date, completion: @escaping (Double, Error?) -> Void) {
//        let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
//        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: date), end: Calendar.current.startOfDay(for: date).addingTimeInterval(86400), options: .strictStartDate)
//        
//        let query = HKStatisticsQuery(quantityType: energyQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
//            guard let result = result, let sum = result.sumQuantity() else {
//                completion(0.0, error)
//                return
//            }
//            DispatchQueue.main.async {
//                self.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
//            }
//            completion(sum.doubleValue(for: HKUnit.kilocalorie()), nil)
//        }
//
//        healthStore.execute(query)
//    }
//}
