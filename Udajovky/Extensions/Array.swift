//
//  Array.swift
//  Udajovky
//
//  Created by hladek on 03/11/2020.
//

import Foundation

extension Array {
    public mutating func safeAppend(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
    
    public mutating func pop(at index: Int) -> Element {
        let result = self[index]
        self.remove(at: index)
        return result
    }
    
    public mutating func shiftLeft(from index: Int) {
        for i in (index)..<(count - 1) {
            self[i] = self[i + 1]
        }
    }
    
    
    
    
}

extension Array where Element : Comparable {
    func insertionIndex(of value: Element) -> Index {
        var slice : SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if value > slice[middle] {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        return slice.startIndex
    }
}

extension Array where Element: BlockInfo {
    var uniqueReferences : [Element] {
        get {
            var result = [Element]()

            for value in self {
                if !result.contains(where: {$0 === value }) {
                    result.append(value)
                }
            }
            return result
        }
    }
    
    
    internal mutating func replaceReferences(toBeReplaced: Int, with: Int) {
        var indexes: [Int] = []
        for i in 0..<count {
            if self[i] === self[toBeReplaced] {
                indexes.append(i)
            }
        }
        for i in indexes {
            self[i] = self[with]
        }
    }
}
