//
//  Atomic.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 17.06.19.
//

import Foundation

struct Atomic<T> {
    private let semaphore = DispatchSemaphore(value: 1)
    private var _value: T

    init(value: T) {
        self._value = value
    }

    var value: T {
        get {
            semaphore.wait()
            defer {
                semaphore.signal()
            }
            return self._value
        }
        set {
            semaphore.wait()
            defer {
                semaphore.signal()
            }
            _value = newValue
        }
    }

    mutating func swap(_ value: T) -> T {
        self.semaphore.wait()
        defer {
            semaphore.signal()
        }
        let result = self._value
        self._value = value
        return result
    }
}
