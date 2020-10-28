import Foundation

class KDTreePoint<T: Kdtr> {
    var leftSon: Self?
    var rightSon: Self?
    var value
}

protocol KDTreeNode {
    var leftSon: Self? { get set }
    var rightSon: Self? { get set }
    func sonOccupied(direction: KDTreeDirection) -> Bool
    func isLess(than other: Self, dimension: Int) -> Bool
}

extension KDTreeNode {
    func sonOccupied(direction: KDTreeDirection) -> Bool {
        switch direction {
        case .left:
            return leftSon != nil
        case .right:
            return rightSon != nil
        }
    }
    
    mutating func addSon(direction: KDTreeDirection, element: Self) {
        switch direction {
        case .left:
            leftSon = element
        case .right:
            rightSon = element
        }
    }
}



enum KDTreeDirection {
    case left,right
}
