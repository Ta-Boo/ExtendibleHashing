import Foundation

class KDPoint<T: KDNode> {
    var leftSon: KDPoint?
    var rightSon: KDPoint?
    var parrent: KDPoint?
    var deleted: Bool = false
    var value: T
    var dimension: Int
    
    var isLeaf: Bool {
        get {
            return leftSon == nil && rightSon == nil
        }
    }
    
    init(_ other: KDPoint) {
        self.leftSon = other.leftSon
        self.rightSon = other.rightSon
        self.parrent = other.parrent
        self.deleted = other.deleted
        self.value = other.value
        self.dimension = other.dimension
    }
    
    
    init(value: T,dimension: Int, parrent: KDPoint? = nil) {
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
    func replaceParentOfSon(at direction: KDDirection, with element: KDPoint<T>?) {
        switch direction {
        case .left:
            leftSon?.parrent = element
        case .right:
            rightSon?.parrent = element
        }
    }
    
    
}

extension KDPoint {
    var hasLeftSon: Bool {
        get {
            return leftSon != nil
        }
    }
    
    var hasRightSon: Bool {
        get {
            return rightSon != nil
        }
    }
}

protocol KDNode: Identifiable, KDComparable {
    var id : Int { get }
    var desc: String { get }
    
    
    func equals(to other: Self) -> Bool
}

protocol KDComparable {
    func compare(to other: Self, dimension: Int) -> KDCompare
    static func == (lhs: Self, rhs: Self) -> Bool
}

enum KDDirection {
    case left, right
}

enum KDCompare {
    case less, equals, more
}

struct DimensionedPoint<T: KDNode> {
    let point: KDPoint<T>
    let dimension: Int
}

struct PointWrapper<T: KDNode> {
    let point: KDPoint<T>
    let direction: KDDirection
}
