//
//  BlockInfo.swift
//  Udajovky
//
//  Created by hladek on 30/11/2020.
//

import Foundation

final class BlockInfo {
    var address: Int
    var neigbourAddress: Int
    var recordsCount: Int
    
    init(address: Int, neigbourAddress: Int, recordsCount: Int) {
        self.address = address
        self.neigbourAddress = neigbourAddress
        self.recordsCount = recordsCount
    }
    
    init() {
        self.address = -1
        self.neigbourAddress = -1
        self.recordsCount = 0
    }
}

extension BlockInfo: Storable {
    var byteSize: Int {
        return 24
    }
    
    var desc: String {
        return ""
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: address.toByteArray())
        result.append(contentsOf: neigbourAddress.toByteArray())
        result.append(contentsOf: recordsCount.toByteArray())
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> BlockInfo {
        let address = Int.fromByteArray(Array(array[0..<8]))
        let neigbourAddress = Int.fromByteArray(Array(array[8..<16]))
        let recordsCount = Int.fromByteArray(Array(array[16..<24]))

        let result = BlockInfo(address: address, neigbourAddress: neigbourAddress, recordsCount: recordsCount)
        return result
    }
    
    static func instantiate() -> BlockInfo {
        BlockInfo()
    }    
}
