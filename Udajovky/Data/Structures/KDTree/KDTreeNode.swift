import Foundation

class KDPoint<T: KDNode> {
    var value: T
    var leftSon: KDPoint?
    var rightSon: KDPoint?
    var parrent: KDPoint?
    var deleted: Bool = false
    var dimension: Int

    var isLeaf: Bool {
        return leftSon == nil && rightSon == nil
    }

    init(_ other: KDPoint) {
        leftSon = other.leftSon
        rightSon = other.rightSon
        parrent = other.parrent
        deleted = other.deleted
        value = other.value
        dimension = other.dimension
    }

    init(value: T, dimension: Int, parrent: KDPoint? = nil) {
        self.value = value
        self.parrent = parrent
        self.dimension = dimension
    }

    func sonOccupied(direction: KDDirection) -> Bool {
        switch direction {
        case .left:
            return leftSon != nil
        case .right:
            return rightSon != nil
        }
    }

    func deleteSon(at direction: KDDirection) {
        switch direction {
        case .left:
            leftSon = nil
        case .right:
            rightSon = nil
        }
    }

    func replaceSon(at direction: KDDirection, with element: KDPoint<T>?) {
        switch direction {
        case .left:
            leftSon = element
        case .right:
            rightSon = element
        }
    }
    
    func replace(son: KDPoint<T>, with replacement: KDPoint<T> ) {
        if leftSon == nil {
            rightSon!.value = replacement.value
        } else {
            if  leftSon === son {
                leftSon!.value = replacement.value
            } else {
                rightSon!.value = replacement.value
            }
        }
    }
    
    func delete(son: KDPoint<T>) {
        if leftSon == nil {
            rightSon = nil
        } else {
            if  leftSon!.value.equals(to: son.value) {
                leftSon!.parrent = nil
                leftSon = nil
            } else {
                rightSon!.parrent = nil
                rightSon = nil
            }
        }
    }
    
    

    func replaceParentOfSon(at direction: KDDirection, with element: KDPoint<T>?) {
        switch direction {
        case .left:
            leftSon?.parrent = element
        case .right:
            rightSon?.parrent = element
        }
    }
    
    func removeReferenceInParent() -> Bool {
        guard let parrent = parrent else {
            return false // it is root point
        }
        if parrent.leftSon === self {
            parrent.leftSon = nil
            return true
        } else {
            parrent.rightSon = nil
            return true
        }
    }
}

extension KDPoint {
    var hasLeftSon: Bool {
        return leftSon != nil
    }

    var hasRightSon: Bool {
        return rightSon != nil
    }

    func hasSon(_ direction: KDDirection) -> Bool {
        switch direction {
        case .left:
            return hasLeftSon
        case .right:
            return hasRightSon
        }
    }
}
protocol Serializable {
    func serialize() -> String
    static func deserialize(from input: String) -> Self
}

protocol KDNode: Identifiable, KDComparable {
    var id: Int { get }
    var desc: String { get }


    func equals(to other: Self) -> Bool
}

protocol KDComparable {
    func compare(to other: Self, dimension: Int) -> KDCompare
    func isBetween (lower: Self, upper: Self) -> Bool
    static func == (lhs: Self, rhs: Self) -> Bool
}

enum KDDirection {
    case left, right
    var isLeft: Bool {
        switch self {
        case .left:
            return true
        default:
            return false
        }
    }
    var isRight: Bool {
        switch self {
        case .right:
            return true
        default:
            return false
        }
    }
    
}

enum KDCompare {
    case less, equals, more
}

extension KDCompare {
    var isLess: Bool {
        switch self {
        case .less:
            return true
        default:
            return false
        }
    }
    
    var isEqual: Bool {
        switch self {
        case .equals:
            return true
        default:
            return false
        }
    }
    
    var isMore: Bool {
        switch self {
        case .more:
            return true
        default:
            return false
        }
    }
    
    var isMoreOrEqual: Bool {
        switch self {
        case .more, .equals:
            return true
        default:
            return false
        }
    }
    
    var isLessOrEqual: Bool {
        switch self {
        case .less, .equals:
            return true
        default:
            return false
        }
    }

}

struct DimensionedPoint<T: KDNode> {
    let point: KDPoint<T>
    let dimension: Int
}

struct PointWrapper<T: KDNode> {
    let point: KDPoint<T>
    let direction: KDDirection
}
