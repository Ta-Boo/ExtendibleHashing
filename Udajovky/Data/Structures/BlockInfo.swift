//
//  BlockInfo.swift
//  Udajovky
//
//  Created by hladek on 30/11/2020.
//

import Foundation

final class BlockInfo {
    var address: Int
//    var neigbourAddress: Int
    var nextBlockAddress: Int
    var recordsCount: Int
    var depth: Int
    
    init(address: Int, recordsCount: Int, depth: Int, nextBlockAddress: Int) {
        self.address = address
        self.nextBlockAddress = nextBlockAddress
        self.recordsCount = recordsCount
        self.depth = depth
    }
    
    init() {
        self.address = -1
        self.recordsCount = 0
        self.depth = 1
        self.nextBlockAddress = -1
    }
}

extension BlockInfo: Storable {
    var byteSize: Int {
        return 32
    }
    
    var desc: String {
        return
            " \n\t(address: \(address)  recordsCount: \(recordsCount) depth: \(depth)), next: \(nextBlockAddress)"
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: address.toByteArray())
        result.append(contentsOf: recordsCount.toByteArray())
        result.append(contentsOf: depth.toByteArray())
        result.append(contentsOf: nextBlockAddress.toByteArray())
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> BlockInfo {
        let address = Int.fromByteArray(Array(array[0..<8]))
        let recordsCount = Int.fromByteArray(Array(array[8..<16]))
        let depth = Int.fromByteArray(Array(array[16..<24]))
        let nextBlockAddress = Int.fromByteArray(Array(array[24..<32]))

        let result = BlockInfo(address: address, recordsCount: recordsCount, depth: depth, nextBlockAddress: nextBlockAddress)
        return result
    }
    
    static func instantiate() -> BlockInfo {
        BlockInfo()
    }    
}
