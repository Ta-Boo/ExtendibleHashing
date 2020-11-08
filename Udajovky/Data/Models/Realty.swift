//
//  Realty.swift
//  Udajovky
//
//  Created by hladek on 13/10/2020.
//

import Foundation

class Realty: KDNode {
    
    private enum RealtyDimensions: Int {
        case latitude = 1
        case longitude = 2
    }
    
   
    var gpsPossition: GpsPossition
    var id: Int
    var registerNumber: Int
    var description: String
    var plots: [Plot]
    var desc: String {
        return "GPS: \(gpsPossition)"
    }
    
    var plotsDescription: String {
        var result = "["
        for plot in plots {
            result.append("\(plot.gpsPossition.lattitude), \(plot.gpsPossition.longitude) |")
        }
        if !plots.isEmpty {
            result = String(result.dropLast(2))
        }
        result.append("]")
        return result
    }

    init(registerNumber: Int, description: String, plots: [Plot], gpsPossition: GpsPossition, id: Int) {
        self.registerNumber = registerNumber
        self.description = description
        self.plots = plots
        self.gpsPossition = gpsPossition
        self.id = id
    }
    
    init (gpsPossition: GpsPossition) {
        self.registerNumber = 0
        self.description = ""
        self.plots = []
        self.gpsPossition = gpsPossition
        self.id = 0
    }
    
    func equals(to other: Realty) -> Bool {
        return id == other.id
    }
    
    func addPlots(_ plots: [Plot]) {
        for plot in plots {
            self.plots.append(plot)
        }
    }
    
    func compare(to other: Realty, dimension: Int) -> KDCompare {
        switch dimension {
        case RealtyDimensions.latitude.rawValue:
            if gpsPossition.lattitude == other.gpsPossition.lattitude {
                return .equals
            } else {
                return gpsPossition.lattitude < other.gpsPossition.lattitude ? .less : .more
            }
        case RealtyDimensions.longitude.rawValue:
            if gpsPossition.longitude == other.gpsPossition.longitude {
                return .equals
            } else {
                return gpsPossition.longitude < other.gpsPossition.longitude ? .less : .more
            }

        default:
            fatalError("Dimension \(dimension) is not present in this type! Choose dimension bellow: \(PlotDimensions.RawValue.max)!")
        }
    }
    
    func isBetween(lower: Realty, upper: Realty) -> Bool {
        return (lower.gpsPossition.lattitude ... upper.gpsPossition.lattitude).contains(self.gpsPossition.lattitude) &&
            (lower.gpsPossition.longitude ... upper.gpsPossition.longitude).contains(self.gpsPossition.longitude)
    }
    

    static func == (lhs: Realty, rhs: Realty) -> Bool {
        return lhs.gpsPossition == rhs.gpsPossition
    }
}
