import Foundation

class KDPoint<T: KDNode> {
    var leftSon: KDPoint?
    var rightSon: KDPoint?
    var parrent: KDPoint?
    var value: T
    
    var isLeaf: Bool {
        get {
            return leftSon == nil && rightSon == nil
        }
    }
    
    
    init(value: T, parrent: KDPoint? = nil) {
        self.value = value
        self.parrent = parrent
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

protocol KDNode {
    var desc: String { get }
    func compare(to other: Self, dimension: Int) -> KDCompare
}

enum KDDirection {
    case left, right
}

enum KDCompare {
    case less, equals, more
}

struct PointWrapper<T: KDNode> {
    let point: KDPoint<T>
    let direction: KDDirection
    let dimension: Int
    
//    func unwrap() -> KDPoint<T>? {
//        switch direction {
//        case .left:
//            return point.parrent?.leftSon
//        case .right:
//            return point.parrent?.rightSon
//        }
//    }
}
