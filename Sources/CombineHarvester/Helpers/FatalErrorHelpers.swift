//
//  FatalErrorHelpers.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 17.06.19.
//

import Foundation

struct FatalErrorHelpers {
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        self.fatalErrorClosure = closure
    }

    static func restoreFatalError() {
        self.fatalErrorClosure = self.defaultFatalErrorClosure
    }
}

// Override the default implementation of fatal errors so that they can be tested
func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorHelpers.fatalErrorClosure(message(), file, line)
}
