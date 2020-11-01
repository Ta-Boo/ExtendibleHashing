//
//  Plot.swift
//  Udajovky
//
//  Created by hladek on 13/10/2020.
//

import Foundation

enum PlotDimensions: Int {
    case registerNumber = 1
    case description = 2
    case realties = 3
    case gpsPossition = 4
}

final class Plot: KDNode {
    var id: Int
    let registerNumber: Int
    let description: Int
    let realties: [Realty]
    let gpsPossition: Int
    
    var desc: String {
        get {
            return "Number: \(registerNumber) \n Description: \(description) \n Realties: \(realties.count) \n GPS: \(gpsPossition) \n"
        }
    }

    init(registerNumber: Int, description: Int, realties: [Realty], gpsPossition: Int, id: Int) {
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
        return self.id == other.id
    }

    func compare(to other: Plot, dimension: Int) -> KDCompare {
        switch dimension {
        case PlotDimensions.registerNumber.rawValue:
            if registerNumber == other.registerNumber {
                return .equals
            } else {
                return registerNumber < other.registerNumber ? .less : .more
            }
        case PlotDimensions.description.rawValue:
            if description == other.description {
                return .equals
            } else {
                return description < other.description ? .less : .more
            }
        case PlotDimensions.realties.rawValue:
            if realties.count == other.realties.count {
                return .equals
            } else {
                return realties.count < other.realties.count ? .less : .more
            }
        case PlotDimensions.gpsPossition.rawValue:
            if gpsPossition == other.gpsPossition {
                return .equals
            } else {
                return gpsPossition < other.gpsPossition ? .less : .more
            }
        default:
            fatalError("Dimension \(dimension) is not present in this type! Choose dimension bellow: \(PlotDimensions.RawValue.max)!")
        }
    }
}











//MARK: Testing purposes only
enum KDTreePointImplementationKeys: Int {
    case number = 1
    case name = 2
    case speed = 3
}

final class KDTreePointImplementation: KDNode {
    let id: Int
    
    
    var desc: String  {
        get {
            return "\(number), \(name), \(speed)"
        }
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
        return self.id == other.id
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
