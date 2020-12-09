import Foundation


extension Int {
    var bitSet: BitSet {
        get {
            let str = String(self, radix: 2)
//            let size = 8
            let size = 16
            var  result = BitSet(size: size)
//            for (index, char) in str.enumerated() {
            for (index, char) in str.reversed().prefix(size).enumerated() {
                if char == "1" {
                    result.set(size - 1 - index)
                }
            }
            return result
        }
    }
}

public struct BitSet {
    private(set) public var size: Int
    
    private let N = 8
    public typealias Byte = UInt8
    fileprivate(set) public var bytes: [Byte]
    
    var desc: String {
        get {
            var result = ""
            for i in 0..<size {
                result.append(isSet(i) ? "1" : "0")
            }
            return result
        }
    }
    
    
    public init(size: Int) {
        precondition(size > 0)
        self.size = size
        let bytesCount = (size + (N-1)) / N
        bytes = [Byte](repeating: 0, count: bytesCount)
    }
    
    private func indexOf(_ i: Int) -> (Int, Byte) {
        precondition(i >= 0)
        precondition(i < size)
        let o = i / N
        let m = Byte(i - o*N)
        return (o, 1 << m)
    }
    
    public mutating func set(_ i: Int) {
      let (j, m) = indexOf(i)
      bytes[j] |= m
    }
    
    public mutating func clear(_ i: Int) {
      let (j, m) = indexOf(i)
      bytes[j] &= ~m
    }
    
    public func isSet(_ i: Int) -> Bool {
       let (j, m) = indexOf(i)
       return (bytes[j] & m) != 0
     }
    
    public func isSetReversed (_ i: Int) -> Bool {
        return isSet(size - i - 1)
    }
    
    public func endIsSet(at: Int) -> Bool {
        return isSet(size - 1 - at)
    }
    public subscript(i: Int) -> Bool {
        get { return isSet(i) }
        set { if newValue { set(i) } else { clear(i) } }
      }

    func toDecimal(depth: Int) -> Int {
        var result = 0
        for index in 0 ..< depth {
//            let addition = Int(pow(2, Double(index))) * (isSet(depth - index - 1) ? 1 : 0)
//            let addition = Int(pow(2, Double(index))) * (isSet(size - index - 1) ? 1 : 0)
            let addition = Int(pow(2, Double(index))) * (isSet(size - depth + index) ? 1 : 0)

            result += addition
        }
        return result
    }
    
    func toRealDecimal() -> Int {
        var result = 0
        for index in 0 ..< size {
            let addition = Int(pow(2, Double(index))) * (isSet(size - index - 1) ? 1 : 0)
//            let addition = Int(pow(2, Double(index))) * (isSet(size - depth + index) ? 1 : 0)
            result += addition
        }
        return result
    }
    
    func differInLast(depth: Int, other: BitSet) -> Bool {
        for index in (0 ..< depth - 1){
            if isSet(index) != other.isSet(index) {
                return false
            }
        }
        if isSet(depth - 1) != other.isSet(depth - 1) {
            return true
        }
        return false
    }
    

}

