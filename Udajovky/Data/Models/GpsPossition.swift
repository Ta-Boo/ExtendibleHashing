//
//  GpsPossition.swift
//  Udajovky
//
//  Created by hladek on 13/10/2020.
//

import Foundation

enum GpsWidth: Character {
    case north = "N"
    case south = "S"
}

enum GpsLength: Character {
    case east = "E"
    case west = "W"
}

struct GpsPossition {
    let width: GpsWidth
    var widthPossition: Double
    let length: GpsLength
    let lengthPossition: Double

    init(width: GpsWidth, widthPossition: Double, length: GpsLength, lengthPossition: Double) {
        self.width = width
        self.widthPossition = widthPossition
        self.length = length
        self.lengthPossition = lengthPossition
    }
}
