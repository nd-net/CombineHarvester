//
//  SubscriptionTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class SubscriptionTests: XCTestCase {
    func testEmptySubscriptionIgnoresEverything() {
        Subscriptions.empty.request(.unlimited)
        Subscriptions.empty.cancel()
    }
}
