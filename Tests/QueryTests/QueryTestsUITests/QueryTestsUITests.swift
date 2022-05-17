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
        
        let text = app.staticTexts["default.value"]
        let changeSecondButton = app.buttons["default.button"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "14")
        
        // `n + (first * second)` where `n` was incremented
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "15")
        
        // `n + (first * second)` where publisher was reset due to View ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "7")
    }
    
    // Initial request:
    // - The value holding the `@Query` can alter the request.
    // - The container view can NOT alter the request.
    func testInitialRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let text = app.staticTexts["initial.value"]
        let changeSecondButton = app.buttons["initial.button"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "7")
        
        // `n + (first * second)` where `n` was incremented
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "8")
        
        // `n + (first * second)` where publisher was reset due to View ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    // Constant request:
    // - The value holding the `@Query` can NOT alter the request.
    // - The container view can alter the request.
    func testConstantRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let text = app.staticTexts["constant.value"]
        let changeSecondButton = app.buttons["constant.button"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `n` was incremented
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "6")
        
        // `n + (first * second)` where publisher was reset due to View ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "6")
    }
    
    // Request binding:
    // - The value holding the `@Query` can alter the request.
    // - The container view can alter the request.
    func testBindingRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let text = app.staticTexts["binding.value"]
        let changeSecondButton = app.buttons["binding.button"]
        
        // `n + (first * second)` where n is zero
        XCTAssertEqual(text.value as? String, "1")
        
        // `n + (first * second)` where `first` was changed
        app.buttons["Change First"].tap()
        XCTAssertEqual(text.value as? String, "5")
        
        // `n + (first * second)` where `second` was changed
        changeSecondButton.tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // `n + (first * second)` where `n` was incremented
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "36")
        
        // `n + (first * second)` where publisher was reset due to View ID change
        app.buttons["Change ID"].tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // Stop publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "35")
        
        // Restart publisher subscription
        app.buttons["Toggle Query Observation"].tap()
        app.buttons["Send Test Notification"].tap()
        XCTAssertEqual(text.value as? String, "36")
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
