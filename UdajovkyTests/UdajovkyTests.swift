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
        
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5, delete: false)
//        for property in properties {
//            extensibleHashing.add(property)
//        }
//        extensibleHashing.save()
        extensibleHashing.printState(headerOnly: true)
        for i in 0..<properties.count {
            _ = (extensibleHashing.find(properties[i])!)
        }
    }
    

    func testInsertAndFind() {
        var generator = SeededGenerator(seed: UInt64(123))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 3)
        
        let repetitions = 1...1000
        var randoms = Array(0...65535)
        randoms.shuffle(using: &generator)
        
        var insertedProperties: [Property] = []
        for i in repetitions {
            if i % 100 == 0 {print("\(i)/1000")}
            let registerNumber = randoms.popLast()!
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
            insertedProperties.append(property)
            extensibleHashing.add(property)
        }
        extensibleHashing.save()
        
        for property in insertedProperties {
            let found = extensibleHashing.find(property)!
            XCTAssert(found.equals(to: property))
        }
    }
    
    func testLoadnSave() {
        testSave()
        testLoad()
    }
    
    func testSave() {
        var generator = SeededGenerator(seed: UInt64(123))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "debug", blockFactor: 5)
        
        let repetitions = 1...1000
        var randoms = Array(0...65535)
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
            let found = extensibleHashing.find(property)!.desc
            print(extensibleHashing.find(property))
//            XCTAssert(found.equals(to: property))
        }
    }
    
    func testLoad() {
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
            let found = extensibleHashing.find(property)!.desc
            print(extensibleHashing.find(property))
//            XCTAssert(found.equals(to: property))
        }
        
    }
    
    func testSeek() {
        let filePath = FileManager.path(to: "ahoj.hsh")
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        } else {
            try! FileManager.default.removeItem(atPath: filePath)
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        let dataFile = FileHandle(forUpdatingAtPath: filePath)!
        dataFile.write(Data(8.toByteArray()))
        dataFile.write(Data(9.toByteArray()))
        dataFile.write(Data(10.toByteArray()))
        try! dataFile.seek(toOffset: 8)
        try! dataFile.seek(toOffset: 8)
        try! dataFile.seek(toOffset: 8)
        dataFile.seek(toFileOffset: 8)
        try! dataFile.seekToEnd()
        try! dataFile.seekToEnd()
        print("9 = ",Int.fromByteArray([UInt8](dataFile.readData(ofLength: 8))))

    }
    
}
