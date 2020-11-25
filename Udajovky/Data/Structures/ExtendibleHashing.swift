//
//  ExtendibleHashing.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

class ExtensibleHashing {
    
    private let fileName: String
    let blockFactor: Int
    var adressary: [Int] = []
    let depth = 1 // 0 ??
    
    private var filePath: String {
        get {
            return FileManager.path(to: "\(fileName).txt")
        }
    }
    
    
    init(fileName: String, blockFactor: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
    }
    
    
    
    func loadBlocks() throws -> [Data] {
        let blocks = [Data]()
        let fileHandle = FileHandle(forReadingAtPath: filePath)!
        let data = fileHandle.readData(ofLength: Property().byteSize)
        fileHandle.seekToEndOfFile()
        print(data)
        fileHandle.closeFile()
        return blocks
    }
    
    func testSave(bytes: [UInt8]) {
        let fileHandle = FileHandle(forWritingAtPath: filePath)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(Data(bytes))
        fileHandle.closeFile()
    }
    
    func testLoad() -> Property {
        let fileHandle = FileHandle(forReadingAtPath: filePath)!
        try! fileHandle.seek(toOffset: UInt64(Property().byteSize))
        let data = fileHandle.readData(ofLength: Property().byteSize)
        let bytes = [UInt8](data)
        return Property.fromByteArray(array: bytes)
    }
    
}
