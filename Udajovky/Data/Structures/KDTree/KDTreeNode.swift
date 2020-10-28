import Foundation

class KDPoint<T: KDNode> {
    var leftSon: KDPoint?
    var rightSon: KDPoint?
    var value: T?
    func sonOccupied(direction: KDTreeDirection) -> Bool {
        switch direction {
        case .left:
            return leftSon != nil
        case .right:
            return rightSon != nil
        }
    }
    
    init(value: T) {
        self.value = value
    }
    
//    func addSon(direction: KDTreeDirection, element: T) {
//        switch direction {
//        case .left:
//            leftSon = Kdpo
//        case .right:
//            rightSon = element
//        }
//    }
}

protocol KDNode {
    func isLess(than other: Self, dimension: Int) -> Bool
}


enum KDTreeDirection {
    case left,right
}
