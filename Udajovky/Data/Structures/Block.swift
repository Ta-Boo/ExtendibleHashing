//
//  Block.swift
//  Udajovky
//
//  Created by hladek on 25/11/2020.
//

import Foundation

final class Block<T: Storable> {
    
    let blockFactor: Int
    var depth: Int
    var records: [T]
    var validCount: Int
    var isFull: Bool {
        get {
            return  validCount == blockFactor
        }
    }
    
    
    
    internal init(blockFactor: Int, records: [T] = [], validCount: Int = 0, depth: Int = 0) {
        self.blockFactor = blockFactor
        self.records = records
        self.validCount = validCount
        self.depth = depth
        self.records = [T](repeating: T.instantiate(), count: blockFactor)
    }
    
    func remove(_e lement: T) {
        //TODO
    }
    
    func add(_ element: T) {
        records[validCount] = element
        validCount += 1
    }
    
}

extension Block: Storable {
    
    var byteSize: Int {
        get {
            return 2*8 + blockFactor * T.instantiate().byteSize
        }
    }
    
    static func instantiate() -> Block {
        return Block(blockFactor: 5)
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: validCount.toByteArray())
        result.append(contentsOf: depth.toByteArray())
        for record in records {
            result.append(contentsOf: record.toByteArray())
        }
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> Block {
        let validCount = Int.fromByteArray(Array(array[0..<8]))
        let depth = Int.fromByteArray(Array(array[8..<16]))
        var records: [T] = []
        var actualStart = 16
        var actualEnd: Int
        for _ in 1...blockFactor {
            actualEnd = actualStart + T.instantiate().byteSize
            let actualArray = Array(array[actualStart..<actualEnd])
            records.append(T.instantiate().fromByteArray(array: actualArray))
            actualStart = actualEnd
        }
        return Block(blockFactor: blockFactor, records: records, validCount: validCount, depth: depth)
    }
    
    
}
