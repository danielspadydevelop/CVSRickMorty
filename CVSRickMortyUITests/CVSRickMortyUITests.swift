//
//  CVSRickMortyUITests.swift
//  CVSRickMortyUITests
//
//  Created by Daniel Spady on 9/9/26.
//

import XCTest

final class CVSRickMortyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Set the initial state (such as interface orientation) required for your
        // tests before they run. The setUp method is a good place to do this.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSearchFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("rick")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        XCTAssertGreaterThan(app.cells.count, 0)

        firstCell.tap()
        XCTAssertTrue(
            app.navigationBars.staticTexts["Rick Sanchez"].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
