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
    var desc: String {
        get {
            return "Number: \(registerNumber) \n Description: \(description) \n Realties: \(realties.count) \n GPS: \(gpsPossition) \n"
        }
    }
    

    let registerNumber: Int
    let description: String
    let realties: [Realty]
    let gpsPossition: Double

    init(registerNumber: Int, description: String, realties: [Realty], gpsPossition: Double) {
        self.registerNumber = registerNumber
        self.description = description
        self.realties = realties
        self.gpsPossition = gpsPossition
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
            if realties == other.realties {
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
    
    var desc: String  {
        get {
            return "\(number), \(name), \(speed)"
        }
    }
    
    static func == (_: KDTreePointImplementation, _: KDTreePointImplementation) -> Bool {
        true
    }
    

    var leftSon: KDTreePointImplementation?
    var rightSon: KDTreePointImplementation?

    var number: Int
    var name: Int
    var speed: Int

    init(number: Int, name: Int, speed: Int) {
        self.number = number
        self.name = name
        self.speed = speed
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
