//
//  KDTree.swift
//  Udajovky
//
//  Created by hladek on 26/10/2020.
//

import Foundation

class KDTree<T: KDTreeNode> {
    let dimensions: Int
    var root: T?
    
    init(dimensions: Int) {
        self.dimensions = dimensions
    }
    
    func add(_ element: T) {
        guard let root = root else {
            self.root = element
            return
        }
        
        var dimension = 1
        var actualNode = root
        var direction = chooseDirection(for: element, presentNode: actualNode, dimension: dimension)
        
        while actualNode.sonOccupied(direction: direction) {
            switch direction {
            case .left:
                actualNode = actualNode.leftSon!
            case .right:
                actualNode = actualNode.rightSon!
            }
            dimension += 1
            dimension = (dimension == dimensions+1) ? 1 : dimension
            direction = chooseDirection(for: element, presentNode: actualNode, dimension: dimension)
        }
        actualNode.addSon(direction: direction, element: element)
        
    }
    
    func chooseDirection(for addedNode: T, presentNode: T, dimension: Int) -> KDTreeDirection {
        return addedNode.isLess(than: presentNode, dimension: dimension) ? .left : .right
    }
    
    
    
}
