//
//  AnyCancellableTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class AnyCancellableTests: XCTestCase {
    private class Canceller: Cancellable {
        var cancellations = 0

        func cancel() {
            self.cancellations += 1
        }
    }

    func testCancelInvocation() {
        var canceller = Canceller()
        var underTest = AnyCancellable(canceller)

        XCTAssertEqual(canceller.cancellations, 0, "if not cancelled, the source is not yet cancelled")

        underTest.cancel()
        XCTAssertEqual(canceller.cancellations, 1, "cancel invokes Cancellable.cancel")

        canceller = Canceller()
        underTest = AnyCancellable(canceller.cancel)

        XCTAssertEqual(canceller.cancellations, 0, "if not cancelled, the source is not yet cancelled")

        underTest.cancel()
        XCTAssertEqual(canceller.cancellations, 1, "cancel invokes closure")
    }

    func testCancelOnlyInvokesTheNestedElementOnce() {
        var canceller = Canceller()
        let underTest = AnyCancellable(canceller)
        underTest.cancel()
        underTest.cancel()
        XCTAssertEqual(canceller.cancellations, 1, "cancel causes exactly one cancellation")

        canceller = Canceller()
        let block1 = {
            _ = AnyCancellable(canceller)
        }
        block1()
        XCTAssertEqual(canceller.cancellations, 1, "deinit causes exactly one cancellation of an uncancelled element")

        canceller = Canceller()
        let block2 = {
            let underTest = AnyCancellable(canceller)
            underTest.cancel()
        }
        block2()
        XCTAssertEqual(canceller.cancellations, 1, "deinit causes exactly one cancellation of a closure")
    }
}
