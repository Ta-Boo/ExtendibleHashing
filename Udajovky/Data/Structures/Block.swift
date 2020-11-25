//
//  Block.swift
//  Udajovky
//
//  Created by hladek on 25/11/2020.
//

import Foundation

final class Block<T: Storable> {
    
    let blockFactor: Int  //TODO: constructor
    var records: [T]
    var validCount: Int
    
    internal init(blockFactor: Int, records: [T] = [], validCount: Int = 0) {
        self.blockFactor = blockFactor
        self.records = records
        self.validCount = validCount
    }
    
}

extension Block: Storable {
    
    var byteSize: Int {
        get {
            return blockFactor * T.instantiate().byteSize + 2*8
        }
    }
    
    static func instantiate() -> Block {
        return Block(blockFactor: 5)
    }
    
    func toByteArray() -> [UInt8] {
        <#code#>
    }
    
    static func fromByteArray(array: [UInt8]) -> Self {
        <#code#>
    }
    
    
}
