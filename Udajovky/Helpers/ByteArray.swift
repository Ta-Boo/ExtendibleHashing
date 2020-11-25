//
//  ByteArray.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

func sizeof <T> (_ : T.Type) -> Int
{
    return (MemoryLayout<T>.size)
}


extension Int {
    func toByteArray() -> [UInt8] {
        var value = self
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    static func fromByteArray(_ value: [UInt8]) -> Self {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: self)
        }
    }
}

extension Double {
    func toByteArray() -> [UInt8] {
        var value = self
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    static func fromByteArray(_ value: [UInt8]) -> Self {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: self)
        }
    }
}

extension String {
    func toByteArray(length: Int) -> [UInt8] {
        let size = length * 2
        var result = String(self).utf8.map{ UInt8($0) }
        if result.count > size {
            result = Array(result[0 ..< size])
        }
        if result.count < size {
            let diff = size - result.count
            for _ in 1...diff {
                result.append(0)
            }
        }
        return result

    }
    
    static func fromByteArray(_ value: [UInt8]) -> Self {
        return String(bytes: value, encoding: .utf8) ?? ""
    }
}
