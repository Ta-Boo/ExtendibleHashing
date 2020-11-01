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
    var id: Int
    let registerNumber: Int
    let description: Int
    let realties: [Realty]
    let gpsPossition: GpsPossition

    var desc: String {
        return "GPS: \(gpsPossition)"
//            return "Number: \(registerNumber) \n Description: \(description) \n Realties: \(realties.count) \n GPS: \(gpsPossition) \n"
    }

    init(registerNumber: Int, description: Int, realties: [Realty], gpsPossition: GpsPossition, id: Int) {
        self.registerNumber = registerNumber
        self.description = description
        self.realties = realties
        self.gpsPossition = gpsPossition
        self.id = id
    }

    static func == (lhs: Plot, rhs: Plot) -> Bool {
        return lhs.registerNumber == rhs.registerNumber &&
            lhs.description == rhs.description &&
            lhs.realties == rhs.realties &&
            lhs.gpsPossition == rhs.gpsPossition
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
