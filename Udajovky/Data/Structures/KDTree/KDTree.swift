//
//  KDTree.swift
//  Udajovky
//
//  Created by hladek on 26/10/2020.
//

import Foundation

class KDTree<T: KDNode> {
    public let dimensions: Int
    
    public var count: Int {
        guard let root = root else {
            return 0
        }
        var counter = 0
        var toBeChecked: [KDPoint<T>] = [root]
        
        while !toBeChecked.isEmpty {
            counter += 1
            let actualPoint = toBeChecked.pop(at: 0)
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
        }
        return counter

    }
    public  var root: KDPoint<T>? //FIXME: Public only for tests ❗️❗️❗️

     public init(dimensions: Int) {
        self.dimensions = dimensions
    }

    //TODO: ▴ Node compare can be wrapped in Point<T>, which  will leads to less disturbing code ❗️
    //      ▴ Refactor duplicity 🔎
    //      ▴ Remove useless coments, everything is gitted 🔎
    //      ▴ ID -> RegisterNumber. wrap it inside as getter computed variable
    //      ▴ change accesibilities 🔎

    // MARK: 🔓 PUBLIC LAYER 🔓

    public func add(_ element: T) {
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
    
    public func findElements(lowerBound: T, upperBound: T) -> [T] {
        return findPoints(lowerBound: lowerBound, upperBound: upperBound).map{ $0.value }
    }

    public func delete(_ element: T) {
        if root == nil {
            fatalError("🚫 You are trying to perform deletion on empty tree! 🚫")
        }
        
        guard var toBeDeleted = findPoint(element) else {
            fatalError("🚫 There is no such an element in Tree 🚫")
        }
        
        if toBeDeleted.parrent == nil, toBeDeleted.isLeaf {
            root = nil
            return
        }
        
        if toBeDeleted.isLeaf {
            toBeDeleted.parrent?.delete(son: toBeDeleted)
        }
        
        var replacement: KDPoint<T>?
        while !toBeDeleted.isLeaf {
            if toBeDeleted.hasRightSon {
                replacement = findMinimum(of: toBeDeleted.rightSon!)
                replacement!.deleted = true
                toBeDeleted.value = replacement!.value
                toBeDeleted.deleted = false
                toBeDeleted = replacement!
            } else if toBeDeleted.hasLeftSon{ //TODO: if  is redundant IMO
                replacement = findMinimum(of: toBeDeleted.leftSon!)
                replacement!.deleted = true
                toBeDeleted.value = replacement!.value
                toBeDeleted.deleted = false
                toBeDeleted.rightSon = toBeDeleted.leftSon
                toBeDeleted.leftSon = nil
                toBeDeleted = replacement!
            }
        }
        replacement?.parrent?.delete(son: replacement!)
    }
    
    // MARK: 🔒 PRIVATE LAYER 🔒
    private func findMinimum(of startingPoint: KDPoint<T>) -> KDPoint<T> {
        var toBeChecked: [KDPoint<T>] = [startingPoint]
        var result = startingPoint
        if startingPoint.isLeaf {
            return startingPoint //TODO: seems to be redundant
        }

        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            
            if actualPoint.value.compare(to: result.value, dimension: startingPoint.parrent?.dimension ?? 1).isLessOrEqual {
                if !actualPoint.deleted {
                    result = actualPoint
                }
            }
            
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
        }
        return result
        
    }
    
    private func findPoints(lowerBound: T, upperBound: T? = nil) -> [KDPoint<T>] {
        guard let root = root else {
            return []
        }
        
        var result: [KDPoint<T>] = []
        var toBeChecked: [KDPoint<T>] = [root]

        guard let upperBound = upperBound else {
            let point = findPoint(lowerBound)
            result.safeAppend(point)
            return result //TODO: why did i put this here ????
        }
        
        var actualPoint: KDPoint<T>
        while !toBeChecked.isEmpty {
            actualPoint = toBeChecked.pop(at: 0)
            if actualPoint.value.isBetween(lower: lowerBound, upper: upperBound) {
                toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
                result.append(actualPoint)
            } else {
                let lowerComparation = actualPoint.value.compare(to: lowerBound, dimension: actualPoint.dimension)
                let upperComparation = actualPoint.value.compare(to: upperBound, dimension: actualPoint.dimension)
                if lowerComparation.isLess {
                    toBeChecked.safeAppend(actualPoint.rightSon)
                } else if upperComparation.isMore {
                    toBeChecked.safeAppend(actualPoint.leftSon)
                } else {
                    toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
                }
            }
        }
        return result
        
        
    }
    
    private func subTreepoints(of point: KDPoint<T>) -> [KDPoint<T>] {
        var result: [KDPoint<T>] = []
        var toBeChecked: [KDPoint<T>] = [point]

        
        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
            result.append(actualPoint)
        }
        
        return result
    }

    private func findPoint(_ element: T) -> KDPoint<T>? {
        guard var actualPoint = root else {
            return nil
        }
        var actualDimension = 1
        let dimensions = self.dimensions + 1
        while !actualPoint.isLeaf {
            if case .less = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.hasLeftSon {
                    actualPoint = actualPoint.leftSon!
                    actualDimension += 1
                    actualDimension = actualDimension % dimensions == 0 ? 1 : actualDimension
                    continue
                } else {
                    fatalError()
                }
            }

            if case .equals = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.value.equals(to: element) {
                    return actualPoint
                } else {
                    if actualPoint.hasRightSon {
                        actualPoint = actualPoint.rightSon!
                        actualDimension += 1
                        actualDimension = actualDimension % dimensions == 0 ? 1 : actualDimension
                        continue
                    } else { return nil }
                }
            }

            if case .more = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.hasRightSon {
                    actualPoint = actualPoint.rightSon!
                    actualDimension += 1
                    actualDimension = actualDimension % dimensions == 0 ? 1 : actualDimension
                    continue
                } else {
                    fatalError()
                }
            }

            actualDimension += 1
            actualDimension = actualDimension % dimensions == 0 ? 1 : actualDimension
        }
        return actualPoint
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

    private func chooseDirection(for addedNode: T, presentNode: KDPoint<T>, dimension: Int) -> KDDirection {
        let comparation = addedNode.compare(to: presentNode.value, dimension: dimension)
        switch comparation {
        case .less:
            return .left
        case .more, .equals:
            return .right
        }
    }
}
