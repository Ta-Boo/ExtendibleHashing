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

final class Plot: KDTreeNode {
    var leftSon: Plot?
    var rightSon: Plot?
    
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
    
    func isLess(than other: Plot, dimension: Int) -> Bool {
        switch dimension {
        case PlotDimensions.registerNumber.rawValue:
            return self.registerNumber < other.registerNumber
        case PlotDimensions.description.rawValue:
            return self.description < other.description
        case PlotDimensions.realties.rawValue:
            return self.realties.count < other.realties.count
        case PlotDimensions.gpsPossition.rawValue:
            return self.gpsPossition < other.gpsPossition
        default:
            fatalError("Dimension \(dimension) is not present in this type! Choose dimension bellow: \(PlotDimensions.RawValue.max)!")
        }
    }
}

enum KDTreePointImplementationKeys: Int {
    case number = 1
    case name = 2
    case speed = 3
}

final class KDTreePointImplementation: KDTreeNode {
    static func == (lhs: KDTreePointImplementation, rhs: KDTreePointImplementation) -> Bool {
        true
    }
    
    var leftSon: KDTreePointImplementation?
    var rightSon: KDTreePointImplementation?
    
    var number: Int
    var name: Int
    var speed: Int
    
    init( number: Int, name: Int, speed: Int) {
        self.number = number
        self.name = name
        self.speed = speed
    }
    
    func isLess(than other: KDTreePointImplementation, dimension: Int) -> Bool {
        switch dimension {
        case KDTreePointImplementationKeys.number.rawValue:
            return self.number < other.number
        case KDTreePointImplementationKeys.name.rawValue:
            return self.name < other.name
        case KDTreePointImplementationKeys.speed.rawValue:
            return self.speed < other.speed
        default:
            fatalError("Selected dimension is not present in this type!")
        }
    }
}
