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
            self.root = KDPoint(value: element, dimension: 1)
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
        if root == nil  {
            fatalError("You are trying to perform deletion on empty tree! Bad, bad developer 🙅‍♂️")
        }
        guard var toBeDeleted = findDimensionedPoint(element)?.point else {
            fatalError("There is no such an element in Tree 🙅‍♂️")
        }
        if toBeDeleted.parrent == nil && toBeDeleted.isLeaf  {
            root = nil
        }
        
        let parentDirection: KDDirection? = toBeDeleted.parrent!.leftSon!.value == element ? .left : .right
        
//                toBeDeleted.parrent?.replaceSon(at: parentDirection, with: KDPoint<KDNode>)
        var replacement: KDPoint<T>?
        while !toBeDeleted.isLeaf {
//            let tempPoint = toBeDeleted
            if toBeDeleted.hasLeftSon {
                replacement = leftMaximum(for: toBeDeleted, by: toBeDeleted.dimension).point
                let replacementCopy = KDPoint(replacement!)
                replacement?.deleted = true
                let temp = KDPoint(toBeDeleted)
                replacementCopy.parrent = temp.parrent
                replacementCopy.leftSon = temp.leftSon
                replacementCopy.rightSon = temp.rightSon
                replacementCopy.parrent?.replaceSon(at: parentDirection!, with: replacementCopy)
                toBeDeleted = replacement!
            } else if toBeDeleted.hasRightSon {
                replacement = rightMinimum(for: toBeDeleted, by: toBeDeleted.dimension).point
            }
        }
    }

    //MARK: 🔒 PRIVATE API 🔒
    
     func findDimensionedPoint(_ element: T) -> DimensionedPoint<T>? {
        guard var actualPoint = root else  {
            return nil
        }
        var actualDimension = 1
        let dimensions = self.dimensions + 1
        //TODO: Mozno by stalo za zvazenie, ci by som nemal vracat [] namiesto jedneho Pointu
        while !actualPoint.isLeaf {
            if case .less = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.hasLeftSon {
                    actualPoint = actualPoint.leftSon!
                    actualDimension += 1
                    actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
                    continue
                }
            }
            
            if case .more = element.compare(to: actualPoint.value, dimension: actualDimension){
                if actualPoint.hasRightSon {
                    actualPoint = actualPoint.rightSon!
                    actualDimension += 1
                    actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
                    continue
                }
            }
            
            if case .equals = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.value == element{
                    return DimensionedPoint(point: actualPoint, dimension: actualDimension)
                } else {
                    if actualPoint.hasRightSon {
                        actualPoint = actualPoint.rightSon!
                        actualDimension += 1
                        actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
                        continue
                    } else {return nil}
                }
            }
            actualDimension += 1
            actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
        }
        return DimensionedPoint(point: actualPoint, dimension: actualDimension)
    }
    
    private func addSon(_ new: T, to present: KDPoint<T>, at dimension: Int) {
        let direction = chooseDirection(for: new, presentNode: present, dimension: dimension)
        let sonDimension = dimension + 1 == dimensions + 1 ? 1 : dimension + 1
        let son = KDPoint(value: new, dimension: sonDimension, parrent: present)
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

        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            if case .more = actualPoint.value.compare(to: minimumPoint.value, dimension: dimension) {
                if !actualPoint.deleted {
                    minimumPoint = actualPoint
                }
            }
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap{ $0 }

        }
        return PointWrapper<T>(point: minimumPoint, direction: .left)
    }
    
    func rightMinimum(for startingNode: KDPoint<T>, by dimension: Int) -> PointWrapper<T> {
        guard var minimumPoint = startingNode.rightSon else {
            fatalError("You are trying to find minimum, while right subtree is empty!")
        }
        var toBeChecked: [KDPoint<T>] = [minimumPoint]
        
        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            if case .less = actualPoint.value.compare(to: minimumPoint.value, dimension: dimension) {
                if !actualPoint.deleted {
                    minimumPoint = actualPoint
                }
            }
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap{ $0 }
        }
        return PointWrapper<T>(point: minimumPoint, direction: .left)
    }

}
