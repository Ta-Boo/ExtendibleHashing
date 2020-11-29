//
//  UdajovkyTests.swift
//  UdajovkyTests
//
//  Created by hladek on 26/10/2020.
//

import XCTest

class UdajovkyTests: XCTestCase {
    
    func testStaticOperations() {
        let properties = [
            Property(registerNumber: 0, id: 0, description: "Žilina", position: GPS(lat: 43.123, long: 164.3291)),
            Property(registerNumber: 1, id: 100, description: "Košice", position: GPS(lat: 43.123, long: 364.3291)),
            Property(registerNumber: 2, id: 149, description: "Martin", position: GPS(lat: 13.123, long: 634.3291)),
            Property(registerNumber: 3, id: 187, description: "Levice", position: GPS(lat: 43.123, long: 624.3291)),
            Property(registerNumber: 4, id: 165, description: "Trnava", position: GPS(lat: 53.123, long: 614.3291)),
            Property(registerNumber: 5, id: 182, description: "Snina", position: GPS(lat: 23.123, long: 641.3291)),
            Property(registerNumber: 6, id: 160, description: "Senica", position: GPS(lat: 14.123, long: 164.3291)),
            Property(registerNumber: 7, id: 108, description: "Nitra", position: GPS(lat: 15.123, long: 564.3291)),
            Property(registerNumber: 8, id: 0, description: "Poprad", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 100, description: "Lučenec", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 233, description: "Zvolen", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 240, description: "Prešov", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 183, description: "Púchov", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 15, description: "Ilava", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 60, description: "Brezno", position: GPS(lat: 11.123, long: 664.3291)),
        ]
        
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5)
        for property in properties {
            extensibleHashing.add(property)
        }
        
        for i in 0..<properties.count {
            print(extensibleHashing.find(properties[i])!.desc)
        }
    }
    

    func testInsertAndFind() {
        var generator = SeededGenerator(seed: UInt64(1))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
        
        var uniques : [Int] = []
        let range = 1...120
        for i in range {
            uniques.append(i)
        }
        
        uniques.shuffle(using: &generator)
        
        var insertedProperties: [Property] = []
        for i in range {
            if i % 100 == 0 {print("\(i)/1000")}
            let registerNumber = uniques.popLast()!
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
            extensibleHashing.add(property)
        }
        
        for property in insertedProperties {
            let found = extensibleHashing.find(property)!
            XCTAssert(found.equals(to: property))
        }
    }
    
}
