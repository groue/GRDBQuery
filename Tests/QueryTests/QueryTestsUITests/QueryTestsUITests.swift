//
//  QueryTestsUITests.swift
//  QueryTestsUITests
//
//  Created by Gwendal Roué on 17/05/2022.
//

import XCTest

class QueryTestsUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // Default request:
    // - The value holding the `@Query` can alter the request.
    // - The container view can NOT alter the request.
    @MainActor func testDefaultRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        app.radioButtons["Tab 1"].tap()
        
        let text = app.staticTexts["default.value"]
        let changeRequestButton = app.buttons["default.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "14")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "15")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "7")
    }
    
    // Initial request:
    // - The value holding the `@Query` can alter the request.
    // - The container view can NOT alter the request.
    @MainActor func testInitialRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        app.radioButtons["Tab 1"].tap()
        
        let text = app.staticTexts["initial.value"]
        let changeRequestButton = app.buttons["initial.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "8")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    // Constant request:
    // - The value holding the `@Query` can NOT alter the request.
    // - The container view can alter the request.
    @MainActor func testConstantRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        app.radioButtons["Tab 1"].tap()
        
        let text = app.staticTexts["constant.value"]
        let changeRequestButton = app.buttons["constant.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    // Request binding:
    // - The value holding the `@Query` can alter the request.
    // - The container view can alter the request.
    @MainActor func testBindingRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        app.radioButtons["Tab 1"].tap()
        
        let text = app.staticTexts["binding.value"]
        let changeRequestButton = app.buttons["binding.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "36")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "36")
    }
    
    @MainActor func testQueryObservationAlways() {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        let text = app.staticTexts["queryObservation.always.value"]
        let notificationButton = app.buttons["queryObservation.always.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.radioButtons["queryObservation.always"].tap()
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.always"].tap()
        XCTAssertEqual(text.value as? String, "7")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "8")
        
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.always"].tap()
        XCTAssertEqual(text.value as? String, "9")
    }
    
    @MainActor func testQueryObservationOnRender() {
        // TODO: find a way to have a testable difference between onRender and onAppear
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        let text = app.staticTexts["queryObservation.onRender.value"]
        let notificationButton = app.buttons["queryObservation.onRender.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.radioButtons["queryObservation.onRender"].tap()
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.onRender"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.onRender"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    @MainActor func testQueryObservationOnAppear() {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].tap()
        }
        
        let text = app.staticTexts["queryObservation.onAppear.value"]
        let notificationButton = app.buttons["queryObservation.onAppear.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.radioButtons["queryObservation.onAppear"].tap()
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.onAppear"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        app.radioButtons["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.radioButtons["queryObservation.onAppear"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
}
