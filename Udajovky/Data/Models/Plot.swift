//
//  Plot.swift
//  Udajovky
//
//  Created by hladek on 13/10/2020.
//

import Foundation

enum PlotDimensions: Int {
    case latitude = 1
    case longitude = 2
}

final class Plot: KDNode {
    var gpsPossition: GpsPossition
    let id: Int
    var registerNumber: Int
    var description: String
    var realties: [Realty]

    var desc: String {
        return "GPS: \(gpsPossition)"
    }
    
    var realtiesDescription: String {
        var result = "["
        for realty in realties {
            result.append("\(realty.gpsPossition.lattitude), \(realty.gpsPossition.longitude) |")
        }
        if !realties.isEmpty {
            result = String(result.dropLast(2))
        }
        result.append("]")
        return result
    }

    init(registerNumber: Int, description: String, realties: [Realty], gpsPossition: GpsPossition, id: Int) {
        self.registerNumber = registerNumber
        self.description = description
        self.realties = realties
        self.gpsPossition = gpsPossition
        self.id = id
    }
    
    init(gpsPossition: GpsPossition) {
        self.registerNumber = 0
        self.description = ""
        self.realties = []
        self.gpsPossition = gpsPossition
        self.id = 0
    }

    static func == (lhs: Plot, rhs: Plot) -> Bool {
        return lhs.gpsPossition == rhs.gpsPossition
    }

    func isBetween(lower: Plot, upper: Plot) -> Bool {
        return (lower.gpsPossition.lattitude ... upper.gpsPossition.lattitude).contains(self.gpsPossition.lattitude) &&
            (lower.gpsPossition.longitude ... upper.gpsPossition.longitude).contains(self.gpsPossition.longitude)
    }

    func equals(to other: Plot) -> Bool {
        return id == other.id
    }

    func compare(to other: Plot, dimension: Int) -> KDCompare {
        switch dimension {
        case PlotDimensions.latitude.rawValue:
            if gpsPossition.lattitude == other.gpsPossition.lattitude {
                return .equals
            } else {
                return gpsPossition.lattitude < other.gpsPossition.lattitude ? .less : .more
            }
        case PlotDimensions.longitude.rawValue:
            if gpsPossition.longitude == other.gpsPossition.longitude {
                return .equals
            } else {
                return gpsPossition.longitude < other.gpsPossition.longitude ? .less : .more
            }

        default:
            fatalError("Dimension \(dimension) is not present in this type! Choose dimension bellow: \(PlotDimensions.RawValue.max)!")
        }
    }
}

// MARK: Testing purposes only

enum KDTreePointImplementationKeys: Int {
    case number = 1
    case name = 2
    case speed = 3
}

final class KDTreePointImplementation: KDNode {
   
    let id: Int

    var desc: String {
        return "\(number), \(name), \(speed)"
    }

    var leftSon: KDTreePointImplementation?
    var rightSon: KDTreePointImplementation?

    var number: Int
    var name: Int
    var speed: Int

    init(number: Int, name: Int, speed: Int, id: Int) {
        self.number = number
        self.name = name
        self.speed = speed
        self.id = id
    }

    static func == (_: KDTreePointImplementation, _: KDTreePointImplementation) -> Bool {
        true
    }

    func isBetween(lower: KDTreePointImplementation, upper: KDTreePointImplementation) -> Bool {
        return (lower.speed...upper.speed).contains(self.speed) &&
            (lower.name...upper.name).contains(self.name) &&
            (lower.number...upper.number).contains(self.number)
    }
    
    func equals(to other: KDTreePointImplementation) -> Bool {
        return id == other.id
    }

    func compare(to other: KDTreePointImplementation, dimension: Int) -> KDCompare {
        switch dimension {
        case KDTreePointImplementationKeys.number.rawValue:
            if number == other.number {
                return .equals
            } else {
                return number < other.number ? .less : .more
            }
        case KDTreePointImplementationKeys.name.rawValue:
            if name == other.name {
                return .equals
            } else {
                return name < other.name ? .less : .more
            }
        case KDTreePointImplementationKeys.speed.rawValue:
            if speed == other.speed {
                return .equals
            } else {
                return speed < other.speed ? .less : .more
            }
        default:
            fatalError("Selected dimension is not present in this type!")
        }
    }
}

extension Plot: Serializable {
    func serialize() -> String {
        var result = ""
        result.append("\(gpsPossition.lattitude);")
        result.append("\(gpsPossition.longitude);")
        result.append("\(id);")
        result.append("\(registerNumber);")
        result.append("\(description)")
        return result

    }
    
    static func deserialize(from input: String) -> Plot{
        let attributes = input.split(separator: ";")
        return Plot(registerNumber: Int(attributes[3])!,
                      description: String(attributes[4]),
                      realties: [],
                      gpsPossition: GpsPossition(lattitude: Double(attributes[0])!, longitude: Double(attributes[1])!),
                      id: Int(attributes[2])!)
    }
    
    
}
