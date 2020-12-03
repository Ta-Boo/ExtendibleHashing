//
//  UdajovkyTests.swift
//  UdajovkyTests
//
//  Created by hladek on 26/10/2020.
//

import XCTest


class UdajovkyTests: XCTestCase {
    let staticProperties = [
        Property(registerNumber: 0, id: 1, description: "Žilina", position: GPS(lat: 43.123, long: 164.3291)),
        Property(registerNumber: 1, id: 101, description: "Košice", position: GPS(lat: 43.123, long: 364.3291)),
        Property(registerNumber: 2, id: 149, description: "Martin", position: GPS(lat: 13.123, long: 634.3291)),
        Property(registerNumber: 3, id: 187, description: "Levice", position: GPS(lat: 43.123, long: 624.3291)),
        Property(registerNumber: 4, id: 165, description: "Trnava", position: GPS(lat: 53.123, long: 614.3291)),
        Property(registerNumber: 5, id: 182, description: "Snina", position: GPS(lat: 23.123, long: 641.3291)),
        Property(registerNumber: 6, id: 160, description: "Senica", position: GPS(lat: 14.123, long: 164.3291)),
        Property(registerNumber: 7, id: 108, description: "Nitra", position: GPS(lat: 15.123, long: 564.3291)),
        Property(registerNumber: 8, id: 0, description: "Poprad", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 9, id: 100, description: "Lučenec", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 10, id: 233, description: "Zvolen", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 11, id: 240, description: "Prešov", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 12, id: 183, description: "Púchov", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 13, id: 15, description: "Ilava", position: GPS(lat: 11.123, long: 664.3291)),
        Property(registerNumber: 14, id: 60, description: "Brezno", position: GPS(lat: 11.123, long: 664.3291)),
    ]

    func testStaticInsertAndFind() {
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5, delete: true)
        for property in staticProperties {
            extensibleHashing.add(property)
        }
        extensibleHashing.save()
        extensibleHashing.printState(headerOnly: true)
        for i in 0..<staticProperties.count {
            _ = (extensibleHashing.find(staticProperties[i])!)
        }
    }
    
    func testStaticDelete() {
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "delete_test", blockFactor: 5, delete: true, logger: true)
        
        for property in staticProperties {
            extensibleHashing.add(property)
            extensibleHashing.printState(headerOnly: false)
        }
        extensibleHashing.save()
        extensibleHashing.printState(headerOnly: false)

        var foundables = staticProperties
        for i in 0...14 {
            let name = staticProperties[i].description
            print("Deleting: \(name)")
            extensibleHashing.delete(staticProperties[i])
            extensibleHashing.printState(headerOnly: false)
        }
        
//        for i in [8,9] {
//            let name = staticProperties[i].description
//            print("Inserting: \(name)")
//            extensibleHashing.add(staticProperties[i])
//            extensibleHashing.printState(headerOnly: false)
//        }
    }
    
    func testRandomDelete() {
        var generator = SeededGenerator(seed: UInt64(1))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5, delete: true, logger: false)
        let repetitions = 1...240
        let maxRep = repetitions.max()!
        var randoms = Array(0...250)
//        var randoms = Array(0...65535)
        randoms.shuffle(using: &generator)

        var insertedProperties: [Property] = []
        for index in repetitions {
            if index % 100 == 0 {print("I: \(index)/\(maxRep)")}

            let registerNumber = randoms.popLast()!
            let property = Property(registerNumber: registerNumber,
                                    id: registerNumber,
                                    description: "asdadasdad",
                                    position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
            extensibleHashing.add(property)
        }
        extensibleHashing.printState()

        for (index, property) in insertedProperties.enumerated() {
            if index % 100 == 0 {print("D: \(index)/\(maxRep)")}
            extensibleHashing.delete(property)
        }
//        extensibleHashing.blockCount = 18
        extensibleHashing.printState()
    }
    
    func testRandomOperations() {
        var generator = SeededGenerator(seed: UInt64(2))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5)
        
        
        var actualProperties: [Property] = []
        var randoms = Array(0...65535)
        randoms.shuffle(using: &generator)
        
        for i in 1...3000 {
            let probability = Double.random(in: 0...1, using: &generator)
            print(i, probability)
            let registerNumber = randoms.popLast()!
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
            if (0..<0.45).contains(probability) || actualProperties.isEmpty {
                actualProperties.append(property)
                extensibleHashing.add(property)
            } else if (0.45 ..< 0.90).contains(probability) {
                actualProperties.shuffle(using: &generator)
                let toBeRemoved = actualProperties.popLast()!
                extensibleHashing.delete(toBeRemoved)
            } else {
                _ = extensibleHashing.find(actualProperties.randomElement(using: &generator)!)!
            }
        }
        
    }
    

    func testInsertAndFind() {
        var generator = SeededGenerator(seed: UInt64(123))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5)
        
        let repetitions = 1...2_000
        var randoms = Array(0...65535)
        randoms.shuffle(using: &generator)
        
        var insertedProperties: [Property] = []
        for i in repetitions {
            if i % 100 == 0 {print("Inserted: \(i)/2_000")}
            let registerNumber = randoms.popLast()!
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
            extensibleHashing.add(property)
        }
        extensibleHashing.save()
        extensibleHashing.printState()
        
        for (i, property) in insertedProperties.enumerated() {
            if i % 100 == 0 {print("tested: \(i)/2_000")}

            let found = extensibleHashing.find(property)!
            XCTAssert(found.equals(to: property))
        }
    }
    
    
    
    func testLoadnSave() {
        wrappedTestSave()
        wrappedTestLoad()
    }
    
    func wrappedTestSave() {
        var generator = SeededGenerator(seed: UInt64(123))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "debug", blockFactor: 5)
        
        let repetitions = 1...50
        var randoms = Array(0...255)
        randoms.shuffle(using: &generator)
        
        var insertedProperties: [Property] = []
        for i in repetitions {
            let registerNumber = randoms.popLast()!
            if i % 100 == 0 {print("\(registerNumber)/1000")}
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "debug info", position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
            extensibleHashing.add(property)
        }
        extensibleHashing.printState(headerOnly: true)
        extensibleHashing.save()
        for property in insertedProperties {
            let found = extensibleHashing.find(property)!
            XCTAssert(found.equals(to: property))
        }
        extensibleHashing.printState(headerOnly: false)
    }
    
    func wrappedTestLoad() {
        var generator = SeededGenerator(seed: UInt64(123))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "debug", blockFactor: 5, delete: false)
        
        let repetitions = 1...1000
        var randoms = Array(0...65535)
        randoms.shuffle(using: &generator)

        var insertedProperties: [Property] = []
        for i in repetitions {
            let registerNumber = randoms.popLast()!
            if i % 100 == 0 {print("\(registerNumber)/1000")}
            let property = Property(registerNumber: 0, id: registerNumber, description: "", position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
        }
        extensibleHashing.printState(headerOnly: true)
        for property in insertedProperties {
            let found = extensibleHashing.find(property)!
            XCTAssert(found.equals(to: property))
        }
        
    }

    
}
