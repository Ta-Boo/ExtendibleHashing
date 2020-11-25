import Foundation

//typealias BitSet = [Bool]
//
//
extension Int {
    var bitSet: BitSet {
        get {
            let str = String(self, radix: 2)
            var  result = BitSet(size: 32)
            for (index, char) in str.reversed().enumerated() {
                if char == "1" {
                    result.set(31 - index)
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
    
    public subscript(i: Int) -> Bool {
        get { return isSet(i) }
        set { if newValue { set(i) } else { clear(i) } }
      }

    func toDecimal(depth: Int) -> Int {
        return 10
    }

}

