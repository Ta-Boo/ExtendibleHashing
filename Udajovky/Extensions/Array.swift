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
}
