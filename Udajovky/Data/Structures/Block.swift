//
//  Block.swift
//  Udajovky
//
//  Created by hladek on 25/11/2020.
//

import Foundation
class AddressedBlock<T> where T: Hashable, T: Storable  {
    let address: Int
    let block: Block<T>

    internal init(address: Int, block: Block<T>) {
        self.address = address
        self.block = block
    }
    
    func toString() -> String{
        return """
               Block(\(address)):
                \(block.toString())
               """
    }
}

final class Block<T>: Identifiable where T: Storable, T: Hashable {
    let id = UUID()
    let blockFactor: Int
    var depth: Int
    var records: [T]
    var validCount: Int
    
    var isFull: Bool {
        get {
            return  validCount == blockFactor
        }
    }
    
    internal init(blockFactor: Int, records: [T] = [], validCount: Int = 0, depth: Int = 1) {
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
    func popLastRecord() -> T{
        let result = records[validCount - 1]
        validCount -= 1
        return result
    }
    
    func delete(_ element: T) {
        let index = records.firstIndex(where: { $0.equals(to: element)})!
        records[index] = records[validCount - 1]
        records[validCount - 1] = T.instantiate()
        validCount -= 1
        
    }
    
    func save(with filehandle: FileHandle, at address: Int) {
        do {
            try filehandle.seek(toOffset: UInt64(address))
            try filehandle.write(contentsOf: Data(toByteArray()))
        } catch {
            fatalError("Failed to save block of data")
        }
        
    }
}

extension Block: Blockable {
    
    var byteSize: Int {
        get {
            return 2*8 + blockFactor * T.instantiate().byteSize
        }
    }
    
    static func instantiate(_ blockFactor: Int) -> Block {
        return Block(blockFactor: blockFactor)
    }
    
     func recordsToString() -> String {
        var result = ""
        for record in records {
            result.append(record.desc)
        }
        return result
    }
    
    func toString() -> String {
        return """
            \t\t BlockFactor:    \(blockFactor)
            \t\t depth:          \(depth)
            \t\t validCount:     \(validCount)
            \t\t records:        \(recordsToString())
            """
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
            let value = T.instantiate().fromByteArray(array: actualArray)
            records.append(value)
            actualStart = actualEnd
        }
        let result = Block(blockFactor: blockFactor, records: records, validCount: validCount, depth: depth)
        for i in 0..<validCount {
            result.records[i] = records[i]
        }
        return result
    }
    
    
}

