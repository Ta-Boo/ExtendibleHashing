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
                let replacementCopy = KDPoint(value: replacement!.value, dimension: toBeDeleted.dimension)
                replacement?.deleted = true
                replacementCopy.parrent = toBeDeleted.parrent
                replacementCopy.leftSon = toBeDeleted.leftSon
                replacementCopy.rightSon = toBeDeleted.rightSon
                replacementCopy.dimension = toBeDeleted.dimension
                switch sonDirection {
                case .left:
                    replacementCopy.leftSon?.parrent = replacementCopy
                case .right:
                    replacementCopy.rightSon?.parrent = replacementCopy
                }
                if firstRound {
                    firstRound = false
                    firstReplacement = replacementCopy
                }
                if parentDirection != nil {
                    replacementCopy.parrent?.replaceSon(at: parentDirection!, with: replacementCopy)
                } else {
                    root = replacementCopy
                }

                inProgress = !toBeDeleted.isLeaf
                toBeDeleted = replacement!
            } else if toBeDeleted.isLeaf {
                inProgress = false
                if parentDirection != nil {
                    toBeDeleted.parrent?.replaceSon(at: parentDirection!, with: nil)
                    toBeDeleted.parrent = nil //TODO: INSPECT REFERENCE CYCLE without this statement  ⭕️
                } else {
                    root = toBeDeleted
                }
            }
        }
        rotateAfterDeletion(point: firstReplacement)
    }

    // MARK: 🔒 PRIVATE API 🔒
    
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
        //TODO: DUPLICITY ❗️
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
                    return actualPoint // TODO: Toto bude robit mozno memory leaky ❗️❗️❗️❗️❗️
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

    private func findPoint(_ element : T) -> [KDPoint<T>]? {
        guard let root = root else {
            fatalError("You are searching in empty tree.")
        }

        var result: [KDPoint<T>] = []

        return nil
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
