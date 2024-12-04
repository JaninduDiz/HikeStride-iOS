//
//  PersistenceControllerTests.swift
//  HikeStrideTests
//
//  Created by Janindu Dissanayake on 2024-06-11.
//

import XCTest

import XCTest
import CoreData
@testable import HikeStride

final class PersistenceControllerTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        viewContext = nil
        persistenceController = nil
        try super.tearDownWithError()
    }

    func testInitialization() throws {
        XCTAssertNotNil(persistenceController)
        XCTAssertNotNil(viewContext)
    }

    func testPreviewSetup() throws {
        let previewController = PersistenceController.preview
        let fetchRequest: NSFetchRequest<HikingDestination> = HikingDestination.fetchRequest()
        let destinations = try previewController.container.viewContext.fetch(fetchRequest)
        XCTAssertEqual(destinations.count, 2)
        for destination in destinations {
            XCTAssertEqual(destination.name, "Sample Trail")
            XCTAssertEqual(destination.location, "Sample Location")
            XCTAssertEqual(destination.difficulty, 5)
            XCTAssertEqual(destination.type, "Loop")
            XCTAssertEqual(destination.info, "Sample Trail in Sample Mountain National Park offers breathtaking panoramic views as it winds through the alpine tundra, reaching elevations over 12,000 feet.")
            XCTAssertEqual(destination.latitude, 37.7749)
            XCTAssertEqual(destination.longitude, -122.4194)
            XCTAssertFalse(destination.isFinished)
        }
    }

    func testSavingAndFetching() throws {
        let newDestination = HikingDestination(context: viewContext)
        newDestination.name = "Test Trail"
        newDestination.location = "Test Location"
        newDestination.difficulty = 3
        newDestination.type = "Out and Back"
        newDestination.info = "Test Trail in Test Park offers a serene environment for hiking."
        newDestination.latitude = 34.0522
        newDestination.longitude = -118.2437
        newDestination.isFinished = true

        do {
            try viewContext.save()
        } catch {
            XCTFail("Failed to save context: \(error.localizedDescription)")
        }

        let fetchRequest: NSFetchRequest<HikingDestination> = HikingDestination.fetchRequest()
        let fetchedDestinations = try viewContext.fetch(fetchRequest)
        XCTAssertEqual(fetchedDestinations.count, 1)
        let fetchedDestination = fetchedDestinations.first
        XCTAssertNotNil(fetchedDestination)
        XCTAssertEqual(fetchedDestination?.name, "Test Trail")
        XCTAssertEqual(fetchedDestination?.location, "Test Location")
        XCTAssertEqual(fetchedDestination?.difficulty, 3)
        XCTAssertEqual(fetchedDestination?.type, "Out and Back")
        XCTAssertEqual(fetchedDestination?.info, "Test Trail in Test Park offers a serene environment for hiking.")
        XCTAssertEqual(fetchedDestination?.latitude, 34.0522)
        XCTAssertEqual(fetchedDestination?.longitude, -118.2437)
        XCTAssertTrue(fetchedDestination?.isFinished ?? false)
    }
}
