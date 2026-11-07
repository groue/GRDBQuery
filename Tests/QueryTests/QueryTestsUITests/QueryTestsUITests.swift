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
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        app.tabViewTab("Tab 1").click()
        
        let text = app.staticTexts["default.value"]
        let changeRequestButton = app.buttons["default.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.click()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.click()
        XCTAssertEqual(text.value as? String, "14")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "15")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].click()
        XCTAssertEqual(text.value as? String, "6")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "6")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
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
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        app.tabViewTab("Tab 1").click()
        
        let text = app.staticTexts["initial.value"]
        let changeRequestButton = app.buttons["initial.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.click()
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.click()
        XCTAssertEqual(text.value as? String, "7")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "8")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].click()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
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
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        app.tabViewTab("Tab 1").click()
        
        let text = app.staticTexts["constant.value"]
        let changeRequestButton = app.buttons["constant.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.click()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.click()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].click()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
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
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        app.tabViewTab("Tab 1").click()
        
        let text = app.staticTexts["binding.value"]
        let changeRequestButton = app.buttons["binding.changeRequestButton"]
        let containerChangeRequestButton = app.buttons["container.changeRequestButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was set to 5 from container view
        containerChangeRequestButton.click()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was set to 7 from ValueView
        changeRequestButton.click()
        XCTAssertEqual(text.value as? String, "35")
        
        // `n + (first * second)` where `n` was incremented
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "36")
        
        // `n + (first * second)` where publisher was reset due to ValueView ID change
        app.buttons["Change ID"].click()
        XCTAssertEqual(text.value as? String, "35")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "35")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].click()
        sharedNotificationButton.click()
        XCTAssertEqual(text.value as? String, "36")
    }
    
    @MainActor func testQueryObservationAlways() {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        let text = app.staticTexts["queryObservation.always.value"]
        let notificationButton = app.buttons["queryObservation.always.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabViewTab("queryObservation.always").click()
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.always").click()
        XCTAssertEqual(text.value as? String, "7")
        
        notificationButton.click()
        XCTAssertEqual(text.value as? String, "8")
        
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.always").click()
        XCTAssertEqual(text.value as? String, "9")
    }
    
    @MainActor func testQueryObservationOnRender() {
        // TODO: find a way to have a testable difference between onRender and onAppear
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        let text = app.staticTexts["queryObservation.onRender.value"]
        let notificationButton = app.buttons["queryObservation.onRender.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabViewTab("queryObservation.onRender").click()
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.onRender").click()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.click()
        XCTAssertEqual(text.value as? String, "7")
        
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.onRender").click()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    @MainActor func testQueryObservationOnAppear() {
        let app = XCUIApplication()
        app.launch()
        
        // Make sure all ui elements are hittable
        XCUIElement.perform(withKeyModifiers: .option) {
            app.buttons[XCUIIdentifierFullScreenWindow].click()
        }
        
        let text = app.staticTexts["queryObservation.onAppear.value"]
        let notificationButton = app.buttons["queryObservation.onAppear.notificationButton"]
        let sharedNotificationButton = app.buttons["shared.notificationButton"]
        
        app.tabViewTab("queryObservation.onAppear").click()
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.onAppear").click()
        XCTAssertEqual(text.value as? String, "6")
        
        notificationButton.click()
        XCTAssertEqual(text.value as? String, "7")
        
        app.tabViewTab("Tab 1").click()
        sharedNotificationButton.click()
        
        app.tabViewTab("queryObservation.onAppear").click()
        XCTAssertEqual(text.value as? String, "6")
    }
}

extension XCUIApplication {
    /// Returns the TabView tab with the given label.
    ///
    /// macOS 27 exposes TabView tabs as tabs, while previous macOS versions
    /// expose them as radio buttons.
    func tabViewTab(_ label: String) -> XCUIElement {
        let elementTypes = [XCUIElement.ElementType.tab, .radioButton].map(\.rawValue)
        return descendants(matching: .any)
            .matching(NSPredicate(format: "elementType IN %@", elementTypes))[label]
    }
}
