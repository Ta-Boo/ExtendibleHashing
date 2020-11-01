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
            return
        }
        
        var parentDirection: KDDirection?
        
        if toBeDeleted.parrent == nil {
            parentDirection = nil
        } else if toBeDeleted.parrent!.leftSon == nil {
            parentDirection = .right
        } else {
            parentDirection = toBeDeleted.parrent!.leftSon!.value == element ? .left : .right
        }

        var replacement: KDPoint<T>?
        var inProgress = true
        while inProgress {
            if toBeDeleted.hasLeftSon {
                replacement = leftMaximum(for: toBeDeleted, by: toBeDeleted.dimension).point
                let replacementCopy = KDPoint(value: replacement!.value, dimension: toBeDeleted.dimension)
                replacement?.deleted = true
                replacementCopy.parrent = toBeDeleted.parrent
                replacementCopy.leftSon = toBeDeleted.leftSon
                replacementCopy.rightSon = toBeDeleted.rightSon
                replacementCopy.leftSon?.parrent = replacementCopy
                if parentDirection != nil {
                    replacementCopy.parrent?.replaceSon(at: parentDirection!, with: replacementCopy)
                } else {
                    root = replacementCopy
                }
                
                inProgress = !toBeDeleted.isLeaf
                toBeDeleted = replacement!
                if toBeDeleted.parrent == nil {
                    parentDirection = nil
                } else if toBeDeleted.parrent?.leftSon == nil {
                    parentDirection = .right
                } else {
                    parentDirection = toBeDeleted.parrent!.leftSon!.value == toBeDeleted.value ? .left : .right
                }
            } else if toBeDeleted.hasRightSon {
                //FIXME: remove DUplicity
                replacement = rightMinimum(for: toBeDeleted, by: toBeDeleted.dimension).point
                let replacementCopy = KDPoint(value: replacement!.value, dimension: toBeDeleted.dimension)
                replacement?.deleted = true
                replacementCopy.parrent = toBeDeleted.parrent
                replacementCopy.leftSon = toBeDeleted.leftSon
                replacementCopy.rightSon = toBeDeleted.rightSon
                replacementCopy.rightSon?.parrent = replacementCopy
                if parentDirection != nil {
                    replacementCopy.parrent?.replaceSon(at: parentDirection!, with: replacementCopy)
                } else {
                    root = replacementCopy
                }
                inProgress = !toBeDeleted.isLeaf
                toBeDeleted = replacement!
                if toBeDeleted.parrent == nil {
                    parentDirection = nil
                } else if toBeDeleted.parrent?.leftSon == nil {
                    parentDirection = .right
                } else {
                    parentDirection = toBeDeleted.parrent!.leftSon!.value == toBeDeleted.value ? .left : .right
                }
            } else  {
                inProgress = false
                toBeDeleted.leftSon = nil
                toBeDeleted.rightSon = nil
                if parentDirection != nil {
                    toBeDeleted.parrent?.replaceSon(at: parentDirection!, with: nil)
                } else {
                    root = toBeDeleted

                }
            }

        }
    }
    
    private func refactorDelete(_ element: T) {
        guard var toBeDeleted = findDimensionedPoint(element)?.point else {
            fatalError("There is no such an element in Tree 🙅‍♂️")
        }
        var replacement: KDPoint<T>?
        var parentDirection: KDDirection?


        if toBeDeleted.hasLeftSon { // has son - direction
            replacement = leftMaximum(for: toBeDeleted, by: toBeDeleted.dimension).point // findReplacement(.direction)
            let replacementCopy = KDPoint(value: replacement!.value, dimension: toBeDeleted.dimension)
            replacement?.deleted = true
            replacementCopy.parrent = toBeDeleted.parrent
            replacementCopy.leftSon = toBeDeleted.leftSon
            replacementCopy.rightSon = toBeDeleted.rightSon
            replacementCopy.leftSon?.parrent = replacementCopy
            if parentDirection != nil {
                replacementCopy.parrent?.replaceSon(at: parentDirection!, with: replacementCopy)
            } else {
                root = replacementCopy
            }
            
            inProgress = !toBeDeleted.isLeaf
            toBeDeleted = replacement!
            if toBeDeleted.parrent == nil {
                parentDirection = nil
            } else if toBeDeleted.parrent?.leftSon == nil {
                parentDirection = .right
            } else {
                parentDirection = toBeDeleted.parrent!.leftSon!.value == toBeDeleted.value ? .left : .right
            }
        }
    }

    //MARK: 🔒 PRIVATE API 🔒
    
    private func findDimensionedPoint(_ element: T) -> DimensionedPoint<T>? {
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
                else {
                    fatalError()
                }
            }
            
            if case .equals = element.compare(to: actualPoint.value, dimension: actualDimension) {
                if actualPoint.value.equals(to: element) {
                    return DimensionedPoint(point: actualPoint, dimension: actualDimension) //TODO: Toto bude robit mozno memory leaky ❗️❗️❗️❗️❗️
                } else {
                    if actualPoint.hasRightSon {
                        actualPoint = actualPoint.rightSon!
                        actualDimension += 1
                        actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
                        continue
                    } else {return nil}
                }
            }
            
            if case .more = element.compare(to: actualPoint.value, dimension: actualDimension){
                if actualPoint.hasRightSon {
                    actualPoint = actualPoint.rightSon!
                    actualDimension += 1
                    actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
                    continue
                } else {
                    fatalError()
                }
            }
            
            
            actualDimension += 1
            actualDimension = actualDimension % dimensions == 0 ? 1: actualDimension
        }
        return DimensionedPoint(point: actualPoint, dimension: actualDimension)
    }
    
    private func findPoint(of element: T) -> [KDPoint<T>]? {
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
    
    private func leftMaximum(for startingNode: KDPoint<T>, by dimension: Int) -> PointWrapper<T> {
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
    
    private func rightMinimum(for startingNode: KDPoint<T>, by dimension: Int) -> PointWrapper<T> {
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
