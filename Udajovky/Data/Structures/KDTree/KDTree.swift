//
//  KDTree.swift
//  Udajovky
//
//  Created by hladek on 26/10/2020.
//

import Foundation

class KDTree<T: KDNode> {
    let dimensions: Int
    var root: KDPoint<T>?
    
    init(dimensions: Int) {
        self.dimensions = dimensions
    }
    
    func add(_ element: T) {
        guard let root = root else {
            self.root?.value = element
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
        addSon(element, to: actualNode, at: dimension)
        
    }
    
    private func addSon(_ new: T, to present: KDPoint<T>, at dimension: Int) {
        let direction = chooseDirection(for: new, presentNode: present, dimension: dimension)
        switch direction {
        case .left:
            present.leftSon = KDPoint(value: new)
        case .right:
            present.rightSon = KDPoint(value: new)
        }
    }
    
    func chooseDirection(for addedNode: T, presentNode: KDPoint<T>, dimension: Int) -> KDTreeDirection {
        return (addedNode.isLess(than: presentNode.value!, dimension: dimension)) ? .left : .right
    }
    
    
    
}
