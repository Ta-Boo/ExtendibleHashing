//
//  Property.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

struct GPS {
    let lat: Double
    let long: Double
}


final class Property {
    
    let registerNumber: Int
    let id: Int
    let description: String
    let position: GPS
    private let descriptionLength = 20
    
    var desc: String {
        get {
            return """

                    \t\t\t Register number: \(registerNumber)
                    \t\t\t id: \(id)
                    \t\t\t description: \(description)
                    \t\t\t lat: \(position.lat)
                    \t\t\t long: \(position.long)
                    \t\t\t hash: \(hash.desc)

                    """
        }
    }
    
    init(registerNumber: Int = 0, id: Int = 0, description: String = "", position: GPS = GPS(lat: 0, long: 0)) {
        self.registerNumber = registerNumber
        self.id = id
        self.description = description
        self.position = position
    }
}

extension Property: Hashable {
    var hash: BitSet {
        return id.bitSet
    }
    var name: String {
        get {
            return description
        }
    }
    
    func equals(to other: Property) -> Bool {
        return id == other.id
    }
    
    func fullEquals(to other: Property) -> Bool {
        return  registerNumber == other.registerNumber
            && id == other.id
            && description == other.description
            && position.lat == other.position.lat
            && position.long == other.position.long
    }
    
    
}

extension Property: Storable {
    var byteSize: Int {
        return 2*8 + 20*2 + 2*8
    }
    
    static func instantiate() -> Property {
        return Property()
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: registerNumber.toByteArray())
        result.append(contentsOf: id.toByteArray())
        result.append(contentsOf: description.toByteArray(length: descriptionLength))
        result.append(contentsOf: position.lat.toByteArray())
        result.append(contentsOf: position.long.toByteArray())
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> Property {
        let registerNumber = Int.fromByteArray(Array(array[0..<8]))
        let id = Int.fromByteArray(Array(array[8..<16]))
        let description = String.fromByteArray(Array(array[16..<56]))
        let lat = Double.fromByteArray(Array(array[56..<64]))
        let lng = Double.fromByteArray(Array(array[64..<72]))
        let property = Property(registerNumber: registerNumber, id: id, description: description, position: GPS(lat: lat, long: lng))
        return property
    }
    
    
}
