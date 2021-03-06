//
//  Hashable.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

protocol Storable {
    var byteSize: Int { get }
    var desc: String { get }
    
    func toByteArray() -> [UInt8]
    func fromByteArray(array: [UInt8]) -> Self
    static func instantiate() -> Self
}

protocol Blockable {
    var byteSize: Int { get }
    func toByteArray() -> [UInt8]
    func fromByteArray(array: [UInt8]) -> Self
    static func instantiate(_ blockFactor: Int) -> Self
}
