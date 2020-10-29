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

    //MARK: 🔓 PUBLIC LAYER 🔓
    func add(_ element: T) {
        guard let root = root else {
            self.root = KDPoint(value: element)
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
            dimension = (dimension == dimensions + 1) ? 1 : dimension
            direction = chooseDirection(for: element, presentNode: actualNode, dimension: dimension)
        }
        addSon(element, to: actualNode, at: dimension)
    }
    
    func delete(_ element: T) {
        guard var actualPoint = root else  {
            fatalError("You are trying to perform deletion on empty tree! Bad, bad developer 🙅‍♂️")
        }
        if actualPoint === root && actualPoint.isLeaf  {
            root = nil
        }
        
        var parentPoint: KDPoint<T>? = nil
        var parentDirection: KDDirection? = nil
        var actualDimension = 1
        //TODO: check direction
        
        while !actualPoint.isLeaf {
            let tempPoint = actualPoint
            if actualPoint.hasLeftSon {
                actualPoint = leftMaximum(for: actualPoint, by: actualDimension).point
            } else if actualPoint.hasRightSon {
                
            }
        }
    }

    //MARK: 🔒 PRIVATE API 🔒
    
    private func addSon(_ new: T, to present: KDPoint<T>, at dimension: Int) {
        let direction = chooseDirection(for: new, presentNode: present, dimension: dimension)
        let son = KDPoint(value: new, parrent: present)
        switch direction {
        case .left:
            present.leftSon = son
        case .right:
            present.rightSon = son
        }
        
    }
    
    private func deletePoint( parental:KDPoint<T>, direction: KDDirection) {
        parental.deleteSon(at: direction)
    }
    
    private func chooseDirection(for addedNode: T, presentNode: KDPoint<T>, dimension: Int) -> KDDirection {
        let comparation = addedNode.compare(to: presentNode.value, dimension: dimension)
        switch comparation {
        case .less:
            return .left
        case .more, .equals:
            return .right
        }
    }
    
    func leftMaximum(for startingNode: KDPoint<T>, by dimension: Int) -> PointWrapper<T> {
        guard var minimumPoint = startingNode.leftSon else {
            fatalError("You are trying to find minimum, while right subtree is empty!")
        }
        var toBeChecked: [KDPoint<T>] = [minimumPoint]
        var actualDimension = dimension

        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            if case .more = actualPoint.value.compare(to: minimumPoint.value, dimension: dimension) {
                minimumPoint = actualPoint
            }
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap{ $0 }
            actualDimension += 1
            actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension

        }
        return PointWrapper<T>(point: minimumPoint, direction: .left, dimension: actualDimension)
    }
    
    func rightMinimum(for startingNode: KDPoint<T>, by dimension: Int) -> PointWrapper<T> {
        guard var minimumPoint = startingNode.rightSon else {
            fatalError("You are trying to find minimum, while right subtree is empty!")
        }
        var toBeChecked: [KDPoint<T>] = [minimumPoint]
        var actualDimension = dimension
        
        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            if case .less = actualPoint.value.compare(to: minimumPoint.value, dimension: dimension) {
                minimumPoint = actualPoint
            }
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap{ $0 }
//            actualDimension += 1
//            actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
        }
        return PointWrapper<T>(point: minimumPoint, direction: .left, dimension: actualDimension)
    }

}
