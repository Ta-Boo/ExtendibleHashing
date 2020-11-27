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

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
