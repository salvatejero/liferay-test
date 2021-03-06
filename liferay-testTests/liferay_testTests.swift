//
//  liferay_testTests.swift
//  liferay-testTests
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//
import UIKit
import XCTest
import Pods_liferay_test

@testable import _salvatejero

class liferay_testTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testAppLoad() {
        
        let app = AppModule()
        let baseUrl = "https://www.liferay.com/locations"
        let locations = app.prepareApplication(baseUrl: baseUrl)
        XCTAssertNotNil(locations)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
