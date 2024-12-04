Please go under edit and edit this file as needed for your project.  There is no seperate documentation needed.

# Project Name - HikeStride
# Student Id - IT21151392
# Student Name - Dissanayake D.M.J.C.B

#### 01. Brief Description of Project - An app for hikers to save and manage their favorite hiking destinations and track their activity during the hike
#### 02. Users of the System - Hikers and outdoor enthusiasts
#### 03. What is unique about your solution - Combines destination management with real-time hike tracking using HealthKit. Tracks and displays step count, active calories, walking distance, and speed during hikes. Users can select destinations directly from a map, ensuring accurate location data.
#### 04. Briefly document the functionality of the screens you have 

Screen 1 is the inital view of the application
![Screen-1](https://github.com/SE4020/assignment-02-part-a-main-app-JaninduDiz/assets/87414583/adf9b5f1-3a3f-4aa6-b325-a42be72163a7)

Screen 2 is for Add a new hike to users destination
![Screen-2](https://github.com/SE4020/assignment-02-part-a-main-app-JaninduDiz/assets/87414583/fe7f1424-a276-4a48-ab86-adf12acac376)

Screen 3 view of the destination details with route in map
![Screen-3](https://github.com/SE4020/assignment-02-part-a-main-app-JaninduDiz/assets/87414583/effde9e8-feab-4e78-96be-e630e13d9e79)

Screen 4 is the promt to user to choose a navigation application to get directions for hike
![Screen-4](https://github.com/SE4020/assignment-02-part-a-main-app-JaninduDiz/assets/87414583/530324ab-b48e-4eda-a29b-8294e2013883)

Screen 5 is the Hike tracking view. It shows the health data and activity for an hike
![Screen-5](https://github.com/SE4020/assignment-02-part-a-main-app-JaninduDiz/assets/87414583/ec075ad2-57c4-4de1-8578-cd321a254b81)


#### 05. Give examples of best practices used when writing code
The code below uses consistant naming conventions for variables, uses structures and constants where ever possible. 

```
 struct Destination: Identifiable {
    var id = UUID()
    var name: String
    var distance: String
    var location: String
    var coordinate: CLLocationCoordinate2D
}

 enum MapApp {
    case apple
    case google
}

```
The code below is a reusable component used to show health data 
```
struct HealthCardView: View {
    let title: String
    let value: String
    let image: String
    let iconColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                
                Spacer().frame(width: 20)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                    Spacer().frame(height: 5)    
                    Text(value)
                        .font(.headline)     
                }
            }
            .padding([.horizontal, .vertical])
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .frame(height: 100)
    }   
}
```

The below code is a helper function to format a time duration string
```
func formatTimeString(_ timeString: String) -> String {
    let components = timeString.split(separator: ":").map { String($0) }
    
    guard components.count == 3 else {
        return "Invalid time format"
    }
    
    let hours = Int(components[0]) ?? 0
    let minutes = Int(components[1]) ?? 0
    let seconds = Int(components[2]) ?? 0
    
    var formattedString = ""
    
    if hours > 0 {
        formattedString += "\(hours)h "
    }
    
    formattedString += "\(String(format: "%02d", minutes))m "
    formattedString += "\(String(format: "%02d", seconds))s"
    
    return formattedString.trimmingCharacters(in: .whitespaces)
}
```

#### 06. UI Components used

The following components were used in the HikeStride App;
   Button, Alert, NavigationView, NavigationLink, List, Picker, Slider, TextField, TextEditor, Forms, Toggle, SwiftUI Stacks and ActionSheet

Additionaly HikeStride App utilize Swift MapKit and HealthKit


#### 07. Testing carried out

The following tests were implemented to vaidate destination entity type for CoreData
```
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
            XCTAssertEqual(destination.info, "Sample Trail in Sample Mountain National Park offers breathtaking panoramic views")
            XCTAssertEqual(destination.latitude, 37.7749)
            XCTAssertEqual(destination.longitude, -122.4194)
            XCTAssertFalse(destination.isFinished)
        }
    }
```

The following classes implemented unit testing for the Helper Functions
```
final class HikeStrideTests: XCTestCase {
    func testFormatTime() {
        XCTAssertEqual(formatTime(3661), "01:01:01")
        XCTAssertEqual(formatTime(0), "00:00:00")
        XCTAssertEqual(formatTime(59), "00:00:59")
        XCTAssertEqual(formatTime(3600), "01:00:00")
        XCTAssertEqual(formatTime(86399), "23:59:59")
    }
    
    func testConvertDateString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date1 = dateFormatter.date(from: "2024-06-10 17:26:59")!
        XCTAssertEqual(convertDateString(date1), "17:26 Jun 10")
        
        let date2 = dateFormatter.date(from: "2024-01-01 00:00:00")!
        XCTAssertEqual(convertDateString(date2), "00:00 Jan 01")
        
        let date3 = dateFormatter.date(from: "2024-12-31 23:59:59")!
        XCTAssertEqual(convertDateString(date3), "23:59 Dec 31")
    }
    
    func testFormatTimeString() {
        XCTAssertEqual(formatTimeString("01:01:01"), "1h 01m 01s")
        XCTAssertEqual(formatTimeString("00:00:59"), "00m 59s")
        XCTAssertEqual(formatTimeString("00:59:59"), "59m 59s")
        XCTAssertEqual(formatTimeString("00:00:00"), "00m 00s")
        XCTAssertEqual(formatTimeString("23:59:59"), "23h 59m 59s")
        XCTAssertEqual(formatTimeString("invalid"), "Invalid time format")
    }
    
}
```
The following classes implemented UI testing for the Add new destination
```
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
        let infoTextEditor = app.textViews.element(boundBy: 0)
        let map = app.maps.element(boundBy: 0)
        let saveButton = app.navigationBars["Add Destination"].buttons["Save"]
        
        XCTAssertTrue(nameField.exists)
        XCTAssertTrue(typePicker.exists)
        XCTAssertTrue(difficultySlider.exists)
        XCTAssertTrue(infoTextEditor.exists)
        XCTAssertTrue(map.exists)
        XCTAssertTrue(saveButton.exists)
        
        nameField.tap()
        nameField.typeText("Test Destination")
        
        typePicker.adjust(toPickerWheelValue: "Loop")
        
        difficultySlider.adjust(toNormalizedSliderPosition: 0.5)
        
        infoTextEditor.tap()
        infoTextEditor.typeText("This is a test destination for hiking.")
                
        map.tap()
        
        let locationField = app.staticTexts["Location"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: locationField, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        saveButton.tap()
        
        let newDestination = app.staticTexts["Test Destination"]
        XCTAssertTrue(newDestination.exists)
    }

}
```


#### 08. Documentation 

(a) Design Choices
    The app was designed with hikers and outdoor enthusiasts in mind providing simple, minimal design, using iOS native features and colors to give a better user experince. Utilize NavigationView to manage the app's navigation flow             effectively. It provides a seamless and intuitive way to navigate between different screens. HealthKit Integration to provide real-time activity tracking during hikes. Using MapKit to allow users to select their hiking destinations         directly from a map provides an interactive and engaging way for users to explore, choose their hiking trails and see routes. Users can get directions to their destination using Apple Maps or Google Maps gave users to chose thier           favorite navigation partner.

(b) Implementation Decisions
    Utilize CoreData for persistent storage of hiking destinations. The app use SwiftUI MapKit to give users to intract with maps to get direction and see route and select location to visit as well as HealthKit to fetch step count, active      calories, and walking distance during hikes. Application requests access for use privacy related information; Health and Location from users. Used proper state management using @State and @EnvironmentObject to handle the authorization      flow and ensure the UI updates appropriately based on the authorization status. 

(c) Challenges
    HealthKit integration and fetching real-time data from HealthKit, such as steps, active calories, walking distance, and walking speed, was complex. Same go to the MapKit intergartion, map interactions and get routes was bit difficult,      but referncing Apple developer documentaion, youtube videos and use GenAI tools helped to get it done. Using coredata to persisit data aslo bit challenging.

#### 09. Reflection
  Better understanding of usage of MapKit and HealthKit would help to get moew from those. I would refer more on those to get more knowlegde.Breaking down the code into more modular components from the start would have made testing and     maintenance easier. While the project was ultimately successful, there were instances where more modular code would have simplified debugging and feature enhancements. I will focus on writing more modular code, creating smaller, reusable components that encapsulate specific functionalities.


#### References 

Documents and Videos
[1]“Meet MapKit for SwiftUI - WWDC23 - Videos,” Apple Developer. https://developer.apple.com/videos/play/wwdc2023/10043/
‌[2]“SwiftUI Maps: How to launch Google Maps from your app,” CodeWithChris, Jun. 24, 2021. https://codewithchris.com/swiftui-google-maps/ (accessed Jun. 12, 2024).
[3]MasteringProgramming, “Opening an address in Maps in Swift/SwiftUI #SwiftUI #IOSDevelopment,” YouTube, Feb. 22, 2022. https://www.youtube.com/watch?v=rWpfyJ8xoj0 (accessed Jun. 12, 2024).
[4]Swift Arcade, “Getting Started With CoreData,” YouTube, Mar. 06, 2020. https://www.youtube.com/watch?v=PyUyWtpKhFM (accessed Jun. 12, 2024).
‌
GenAI Conversations
1. https://chatgpt.com/share/9b975fc2-ec0f-466d-8095-bf7c3795726b
2. https://chatgpt.com/share/857a1eb7-ddda-4679-9e13-4187e80fa661
3. https://chatgpt.com/g/g-L9NbS395h-swift-copilot/c/73cdd614-7c84-4b85-bffa-e77903576377
‌
‌

  

# HikeStride-iOS
