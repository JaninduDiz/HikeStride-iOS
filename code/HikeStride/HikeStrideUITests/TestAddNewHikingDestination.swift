//
//  testAddNewHikingDestination.swift
//  HikeStrideUITests
//
//  Created by Janindu Dissanayake on 2024-06-11.
//

import XCTest

final class TestAddNewHikingDestination: XCTestCase {
    
    func testNavigationToAddHikingDestinationView() {
        let app = XCUIApplication()
        app.launch()
        
        let addButton = app.buttons["Add Item"]
        XCTAssertTrue(addButton.exists)
        
        addButton.tap()
        
        let addDestinationNavBar = app.navigationBars["Add Destination"]
        XCTAssertTrue(addDestinationNavBar.exists)
    }


    func testAddNewHikingDestination() {
        let app = XCUIApplication()
        app.launch()
        
        let addButton = app.buttons["Add Item"]
        addButton.tap()
        
        let nameField = app.textFields["Name"]
        let typePicker = app.pickers["Type"]
        let difficultySlider = app.sliders["Difficulty Level"]
        let infoTextEditor = app.textViews.element(boundBy: 0) // Adjust if there are multiple text views
        let map = app.maps.element(boundBy: 0)
        let saveButton = app.navigationBars["Add Destination"].buttons["Save"]
        
        XCTAssertTrue(nameField.exists)
        XCTAssertTrue(typePicker.exists)
        XCTAssertTrue(difficultySlider.exists)
        XCTAssertTrue(infoTextEditor.exists)
        XCTAssertTrue(map.exists)
        XCTAssertTrue(saveButton.exists)
        
        // Fill in the form
        nameField.tap()
        nameField.typeText("Test Destination")
        
        typePicker.adjust(toPickerWheelValue: "Loop")
        
        difficultySlider.adjust(toNormalizedSliderPosition: 0.5) // Adjust to the desired position
        
        infoTextEditor.tap()
        infoTextEditor.typeText("This is a test destination for hiking.")
        
        // Interact with the map to set a location
        map.tap() // Simulate a tap on the map to select a location
        
        // Wait for the location field to update
        let locationField = app.staticTexts["Location"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: locationField, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Save the new destination
        saveButton.tap()
        
        // Verify the new destination in the list
        let newDestination = app.staticTexts["Test Destination"]
        XCTAssertTrue(newDestination.exists)
    }

}
