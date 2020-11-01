//
//  Realty.swift
//  Udajovky
//
//  Created by hladek on 13/10/2020.
//

import Foundation

class Realty: Equatable {
    let registerNumber: Int
    let description: String

    init(registerNumber: Int, description: String) {
        self.registerNumber = registerNumber
        self.description = description
    }

    static func == (lhs: Realty, rhs: Realty) -> Bool {
        return lhs.registerNumber == rhs.registerNumber && lhs.description == rhs.description
    }
}
