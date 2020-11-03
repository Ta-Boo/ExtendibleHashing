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

    //TODO: ▴ Node compare can be wrapped in Point<T>, which  will leads to less disturbing code
    //      ▴ Refactor duplicity
    //      ▴ Remove useless coments, everything is gitted
    //      ▴
    //      ▴

    // MARK: 🔓 PUBLIC LAYER 🔓

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
        if root == nil {
            fatalError("🚫 You are trying to perform deletion on empty tree! 🚫")
        }
        guard var toBeDeleted = findDimensionedPoint(element) else {
            fatalError("🚫 There is no such an element in Tree 🚫")
        }
        if toBeDeleted.parrent == nil, toBeDeleted.isLeaf {
            root = nil
            return
        }

        var parentDirection: KDDirection?
        var sonDirection: KDDirection
        var replacement: KDPoint<T>?
        var firstReplacementValue: T?
        var firstReplacement: KDPoint<T>?

        var firstRound = true

        var inProgress = true
        while inProgress {
            if toBeDeleted.parrent == nil {
                parentDirection = nil
            } else if toBeDeleted.parrent!.leftSon == nil {
                parentDirection = .right
            } else {
                parentDirection = toBeDeleted.parrent!.leftSon! === toBeDeleted ? .left : .right
            }
            sonDirection = toBeDeleted.hasLeftSon ? .left : .right
            if toBeDeleted.hasSon(sonDirection) { // has son - direction
                replacement = suitableReplacement(for: toBeDeleted, by: toBeDeleted.dimension, direction: sonDirection)
                
                if firstRound {
                    firstRound = false
                    firstReplacementValue = replacement?.value
                    firstReplacement = toBeDeleted
                }

                replacement?.deleted = true
                toBeDeleted.value = replacement!.value
                toBeDeleted.deleted = false
                
                inProgress = !toBeDeleted.isLeaf
                toBeDeleted = replacement!
            } else if toBeDeleted.isLeaf {
                inProgress = false
                if parentDirection != nil {
                    toBeDeleted.parrent?.replaceSon(at: parentDirection!, with: nil)
                    toBeDeleted.parrent = nil
                } else {
                    root = toBeDeleted
                }
            }
        }
        
        guard let firstReplac = firstReplacement,
              let firstVal = firstReplacementValue else {
            return
        }
        let result = KDPoint(firstReplac)
        result.value =  firstVal
        rotateAfterDeletion(point: result)
    }
    
    func findElements(lowerBound: T, upperBound: T) -> [T?] {
        return findPoints(lowerBound: lowerBound, upperBound: upperBound).map{ $0.value }
    }

    // MARK: 🔒 PRIVATE LAYER 🔒
    
//    private func findSplitNode (lowerBound: T, upperBound: T) -> KDPoint<T> {
//        guard var actualPoint = root else {
//            fatalError()
//        }
//        while !actualPoint.isLeaf && (actualPoint.value.compare(to: lowerBound, dimension: actualPoint.dimension).isMoreOrEqual || actualPoint.value.compare(to: upperBound, dimension: actualPoint.dimension).isLessOrEqual) {
//            if actualPoint.value.compare(to: upperBound, dimension: actualPoint.dimension).isMoreOrEqual {
//
//            }
//        }
//
//    }
//    private func refactoredSearch(lowerBound: T, upperBound: T? = nil) -> [KDPoint<T>] {
//    }
//
    private func findPoints(lowerBound: T, upperBound: T? = nil) -> [KDPoint<T>] {
        guard let root = root else {
            return []
        }
        
        var result: [KDPoint<T>] = []
        var toBeChecked: [KDPoint<T>] = [root]

        guard let upperBound = upperBound else {
            let point = findDimensionedPoint(lowerBound)
            result.safeAppend(point)
            return [] // toto treba refaktornut. to najde bod na zaklade id
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
                }
                if upperComparation.isMore {
                    toBeChecked.safeAppend(actualPoint.leftSon)
                }
            }
            
//            let lowerComparation = actualPoint.value.compare(to: lowerBound, dimension: actualPoint.dimension)
//            let upperComparation = actualPoint.value.compare(to: upperBound, dimension: actualPoint.dimension)
//
//            if lowerComparation.isMoreOrEqual && upperComparation.isLessOrEqual{
////                    toBeChecked.append(actualPoint)
//                    result.append(actualPoint)
//                    if actualPoint.hasLeftSon {
//                        let leftSonLowerComparation =  actualPoint.leftSon!.value.compare(to: lowerBound, dimension: actualPoint.dimension)
//                        let leftSonUpperComparation =  actualPoint.leftSon!.value.compare(to: upperBound, dimension: actualPoint.dimension)
//                        if leftSonLowerComparation.isMoreOrEqual && leftSonUpperComparation .isLessOrEqual {
//                            toBeChecked.append(actualPoint.leftSon!)
//                        }
//                    }
//
//                if actualPoint.hasRightSon {
//                    let rightSonLowerComparation =  actualPoint.rightSon!.value.compare(to: lowerBound, dimension: actualPoint.dimension)
//                    let rightSonUpperComparation =  actualPoint.rightSon!.value.compare(to: upperBound, dimension: actualPoint.dimension)
//                    if rightSonLowerComparation.isMoreOrEqual && rightSonUpperComparation.isLessOrEqual {
//                        toBeChecked.append(actualPoint.rightSon!)
//                    }
//                }
//            }
        }
        return result
        
        
    }
    
    private func rotateAfterDeletion(point: KDPoint<T>?) {
        guard let point = point else {
            return
        }
        if point.hasLeftSon {
            let comparation = point.value.compare(to: point.leftSon!.value, dimension: point.dimension)
            if comparation.isMore || comparation.isEqual {
                var subTreePoints = subTreepoints(of: point.leftSon!)
                
                while !subTreePoints.isEmpty  {
                    let actualPoint = subTreePoints.first!
                    subTreePoints.remove(at: 0)

                        actualPoint.leftSon = nil
                        actualPoint.rightSon = nil
                        if !actualPoint.removeReferenceInParent() {
                            root = nil
                        }
                        add(actualPoint.value)
                    
                }
            }
        }
        //TODO: DUPLICITY  ?
        if point.hasRightSon {
            let comparation = point.value.compare(to: point.rightSon!.value, dimension: point.dimension)
            if comparation.isEqual {
                var subTreePoints = subTreepoints(of: point.rightSon!)

                while !subTreePoints.isEmpty  {
                    let actualPoint = subTreePoints.first!
                    subTreePoints.remove(at: 0)
                        actualPoint.leftSon = nil
                        actualPoint.rightSon = nil
                        if !actualPoint.removeReferenceInParent() {
                            root = nil
                        }
                        add(actualPoint.value)
                }
            }
        }
        
        
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

    private func findDimensionedPoint(_ element: T) -> KDPoint<T>? {
        guard var actualPoint = root else {
            return nil
        }
        var actualDimension = 1
        let dimensions = self.dimensions + 1
        // TODO: Mozno by stalo za zvazenie, ci by som nemal vracat [] namiesto jedneho Pointu
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
                    return actualPoint // TODO: reference cycle?
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

//    private func findPoint(_ element : T) -> [KDPoint<T>]? {
//        guard let root = root else {
//            fatalError("You are searching in empty tree.")
//        }
//
//        var result: [KDPoint<T>] = []
//
//        return nil
//    }

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
    
    private func suitableReplacement(for startingNode: KDPoint<T>, by dimension: Int , direction: KDDirection) -> KDPoint<T> {
        var suitablePoint: KDPoint<T>?
        
        switch direction {
        case .left:
            suitablePoint = startingNode.leftSon
        case .right:
            suitablePoint = startingNode.rightSon
        }
        guard var result = suitablePoint else {
            fatalError("Subtree is empty")
        }
        var toBeChecked: [KDPoint<T>] = [result]

        while !toBeChecked.isEmpty {
            let actualPoint = toBeChecked.first!
            toBeChecked.remove(at: 0)
            switch direction {
            case .right:
                if case .less = actualPoint.value.compare(to: result.value, dimension: dimension) {
                    if !actualPoint.deleted {
                        result = actualPoint
                    }
                }
            case .left:
                if case .more = actualPoint.value.compare(to: result.value, dimension: dimension) {
                    if !actualPoint.deleted {
                        result = actualPoint
                    }
                }
            }
            
            toBeChecked += [actualPoint.leftSon, actualPoint.rightSon].compactMap { $0 }
        }
        return result
    }

}
