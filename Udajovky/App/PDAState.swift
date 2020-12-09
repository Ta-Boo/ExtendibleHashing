//
//  PDAState.swift
//  Udajovky
//
//  Created by hladek on 08/12/2020.
//

import Foundation

class AllData<T> where T:Hashable, T:Storable {
    internal init(mainAddressary: [UIBlockInfo],
                  overflowAddressary: [BlockInfo],
                  mainFreeAddresses: [Int],
                  overflowAddresses: [Int],
                  mainBlocks: [AddressedBlock<T>],
                  overflowBlocks: [AddressedBlock<T>]) {
        self.mainAddressary = mainAddressary
        self.overflowAddressary = overflowAddressary
        self.mainFreeAddresses = mainFreeAddresses
        self.overflowAddresses = overflowAddresses
        self.mainBlocks = mainBlocks
        self.overflowBlocks = overflowBlocks
    }
    
    let mainAddressary: [UIBlockInfo]
    let overflowAddressary: [BlockInfo]
    let mainFreeAddresses: [Int]
    let overflowAddresses: [Int]
    let mainBlocks: [AddressedBlock<T>]
    let overflowBlocks: [AddressedBlock<T>]
}


class PDAState {
    static let shared = PDAState()
    var properties = ExtensibleHashing<Property>(fileName: "GPS_System", blockFactor: 3, maxDepth: 3,logger: false)
    var allData : AllData<Property> {
        get {
            return properties.allData
        }
    }
    
    func insert(_ element: Property) {
        properties.add(element)
    }
    
    func delete(_ element: Property) {
        properties.delete(element)
    }
    
    func find(_ element: Property) -> Property? {
        return properties.find(element)
    }
    
    func save() {
        properties.save()
    }
    
    func generate() {
        var generator = SeededGenerator(seed: UInt64(123))
        let repetitions = 1...30
        let max = repetitions.upperBound
        var randoms = Array(0...max)
        randoms.shuffle(using: &generator)
        
        var insertedProperties: [Property] = []
        for i in repetitions {
            if i % 100 == 0 {print("Inserted: \(i)/2_000")}
            let registerNumber = randoms.popLast()!
            let property = Property(registerNumber: Int.random(in: 0...33000), id: registerNumber, description: String.random(length: 23), position: GPS(lat: Double.random(in: -90...90), long: Double.random(in: -90...90)))
            insertedProperties.append(property)
            properties.add(property)
        }
    }
    
}
