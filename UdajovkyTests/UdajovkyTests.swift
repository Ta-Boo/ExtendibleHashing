//
//  UdajovkyTests.swift
//  UdajovkyTests
//
//  Created by hladek on 26/10/2020.
//

import XCTest

class UdajovkyTests: XCTestCase {
    
    func testStaticOperations() {
//        let startTime = CFAbsoluteTimeGetCurrent()
//        var generator = SeededGenerator(seed: UInt64(1234567))
        
    }
    
    func testRandomOperations() throws {
        let operations = 100_000
        for seed in 3421 ... 3421 {
            var generator = SeededGenerator(seed: UInt64(seed))
            for _ in 1...operations {
                let probability = Double.random(in: 0.0 ... 1.0, using: &generator)
                if probability < 0.7 {
                    //TODO: code
                }
            }
        }
    }
}
