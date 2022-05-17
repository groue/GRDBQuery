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
    func testDefaultRequest() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabs["Tab 1"].tap()
        
        let text = app.staticTexts["default.value"]
        let changeSecondButton = app.buttons["default.button"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "14")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "15")
        
        // `n + (first * second)` where publisher was reset due to View ID change
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
    func testInitialRequest() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabs["Tab 1"].tap()
        
        let text = app.staticTexts["initial.value"]
        let changeSecondButton = app.buttons["initial.button"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "8")
        
        // `n + (first * second)` where publisher was reset due to View ID change
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
    func testConstantRequest() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabs["Tab 1"].tap()
        
        let text = app.staticTexts["constant.value"]
        let changeSecondButton = app.buttons["constant.button"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where publisher was reset due to View ID change
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
    func testBindingRequest() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabs["Tab 1"].tap()
        
        let text = app.staticTexts["binding.value"]
        let changeSecondButton = app.buttons["binding.button"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.tap()
        XCTAssertEqual(text.value as? String, "36")
        
        // `n + (first * second)` where publisher was reset due to View ID change
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
    
    func testQueryObservationAlways() {
        let app = XCUIApplication()
        app.launch()
        let text = app.staticTexts["queryObservation.always.value"]
        let notificationButton = app.buttons["queryObservation.always.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabs["queryObservation.always"].tap()
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.always"].tap()
        XCTAssertEqual(text.value as? String, "7")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "8")
        
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.always"].tap()
        XCTAssertEqual(text.value as? String, "9")
    }
    
    func testQueryObservationOnRender() {
        // TODO: find a way to have a testable difference between onRender and onAppear
        let app = XCUIApplication()
        app.launch()
        let text = app.staticTexts["queryObservation.onRender.value"]
        let notificationButton = app.buttons["queryObservation.onRender.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabs["queryObservation.onRender"].tap()
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.onRender"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.onRender"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    func testQueryObservationOnAppear() {
        let app = XCUIApplication()
        app.launch()
        let text = app.staticTexts["queryObservation.onAppear.value"]
        let notificationButton = app.buttons["queryObservation.onAppear.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabs["queryObservation.onAppear"].tap()
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.onAppear"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        app.tabs["Tab 1"].tap()
        sharedNotificationButton.tap()
        
        app.tabs["queryObservation.onAppear"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
}

extension Array {
    mutating func popFirst() -> Element? {
        if isEmpty {
            return nil
        }
        return removeFirst()
    }
}
