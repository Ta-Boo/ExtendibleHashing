//
//  Hashable.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

protocol Hashable {
    var hash: BitSet { get }
    func equals(to other: Self) -> Bool
}
