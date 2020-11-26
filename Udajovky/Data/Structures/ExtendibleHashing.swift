//
//  ExtendibleHashing.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

final class ExtensibleHashing<T> where  T: Hashable, T:Storable {
    private var fileName: String
    var blockFactor: Int
    var addressary: [Int] = []
    var depth = 1
    var blockCount = 0
    
    private let configPostfix = "-config"

    //MARK: Public interface 🔓🔓🔓
   
    //Initial constructor
    init(fileName: String, blockFactor: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        
        if !FileManager.default.fileExists(atPath: pathToFile()) {
            FileManager.default.createFile(atPath: pathToFile(), contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: pathToFile("\(fileName)\(configPostfix)"), contents: nil, attributes: nil)
            let fileHandle = FileHandle(forWritingAtPath: pathToFile())!
            addressary = [0,0]
            for i in 0...1 {
//                print("address = ", i * Block<T>.instantiate(blockFactor).byteSize)
                addBlock(at: i)
            }
            fileHandle.closeFile()
        } else {
            load()
        }
    }
    
    // Loader Constructor
    internal init(fileName: String, blockFactor: Int, addressary: [Int] = [], blockCount: Int, depth: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        self.addressary = addressary
        self.blockCount = blockCount
        self.depth = depth
    }
    
    func add(_ element: T) {
        let fileHandle = FileHandle(forUpdatingAtPath: pathToFile())!
        try! fileHandle.seek(toOffset: UInt64(Block<Property>.instantiate(blockFactor).byteSize * 20))
        var inProgress = true
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let address = UInt64(addressary[hash])
            print("primaryHash: \(element.hash.desc)/hash: \(hash), addres: \(addressary[hash]) ")
            fileHandle.seek(toFileOffset: address)
            let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            var block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            if block.isFull {
                if depth == block.depth {
                    var newAdressary: [Int] = []
                    for address in addressary {
                        newAdressary.append(address)
                        newAdressary.append(address)
                    }
                    depth += 1
                    self.addressary = newAdressary
                }
                //TODO: split block - add new block edit depths
//                block = split(block)
                
            } else {
                block.add(element)
                fileHandle.seek(toFileOffset: UInt64(address))
                fileHandle.write(Data(block.toByteArray()))
                fileHandle.closeFile()
                save()
                
                inProgress = false
            }
        }
        
    }
    
//    private func split(_ block: Block<T>) -> Block<T> {
//
//    }
    
    private func pathToFile(_ name: String? = nil) -> String {
        return FileManager.path(to: "\(name ?? fileName).txt")
    }
    
    private func addBlock(at index: Int) {
        let address = blockCount*Block<T>.instantiate(blockFactor).byteSize
        let fileHandle = FileHandle(forWritingAtPath: pathToFile())!
        fileHandle.seek(toFileOffset: UInt64(address))
        fileHandle.write(Data(Block<T>.instantiate(blockFactor).toByteArray()))
        fileHandle.closeFile()
        addressary[index] = address
        blockCount += 1
    }
    
    private func save() {
        let fileHandle = FileHandle(forWritingAtPath: pathToFile("\(fileName)\(configPostfix)"))!
        fileHandle.write(Data(toByteArray()))
        fileHandle.closeFile()
    }
    
    private func load() {
        let fileHandle = FileHandle(forReadingAtPath: pathToFile("\(fileName)\(configPostfix)"))!
        let data = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()
        let bytes = [UInt8](data)
        let loaded = fromByteArray(array: bytes)
        copy(other: loaded)
    }
    
    private func copy(other: ExtensibleHashing) {
        self.fileName = other.fileName
        self.blockFactor = other.blockFactor
        self.addressary = other.addressary
        self.blockCount = other.blockCount
        self.depth = other.depth
    }
    
    
   //MARK: Testing  🧪🧪🧪
    
    func testSave(bytes: [UInt8]) {
        let fileHandle = FileHandle(forWritingAtPath: pathToFile())!
        fileHandle.seekToEndOfFile()
        fileHandle.write(Data(bytes))
        fileHandle.closeFile()
    }
    
    func testLoad() -> Property {
        let fileHandle = FileHandle(forReadingAtPath: pathToFile())!
        try! fileHandle.seek(toOffset: UInt64(Property().byteSize))
        let data = fileHandle.readData(ofLength: Property().byteSize)
        let bytes = [UInt8](data)
        return Property.instantiate().fromByteArray(array: bytes)
    }
    
    func testBlockSave() {
        let block = Block<Property>(blockFactor: 5)
        let fileHandle = FileHandle(forWritingAtPath: pathToFile())!
        fileHandle.seekToEndOfFile()
        fileHandle.write(Data(block.toByteArray()))
        fileHandle.closeFile()
    }
    
//    func testBlockLoad() {
//        let fileHandle = FileHandle(forReadingAtPath: pathToFile())!
//        try! fileHandle.seek(toOffset: UInt64(Block<Property>.instantiate().byteSize * 20))
//        let data = fileHandle.readData(ofLength: Block<Property>.instantiate().byteSize)
//        let bytes = [UInt8](data)
//        let result = Block<Property>.instantiate().fromByteArray(array: bytes)
//    }
    
}

extension ExtensibleHashing: Storable {
    var byteSize: Int {
        return 20*2 + 3*8 + 8*addressary.count
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: depth.toByteArray())
        result.append(contentsOf: blockFactor.toByteArray())
        result.append(contentsOf: blockCount.toByteArray())
        result.append(contentsOf: fileName.toByteArray(length: 20))
        
        for adress in addressary {
            result.append(contentsOf: adress.toByteArray())
        }
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> ExtensibleHashing {
        let depth = Int.fromByteArray(Array(array[0..<8]))
        let blockFactor = Int.fromByteArray(Array(array[8..<16]))
        let blockCount = Int.fromByteArray(Array(array[16..<24]))
//        let fileName = String.fromByteArray(Array(array[24..<64]))
        var addressary: [Int] = []
        var actualStart = 24
        var actualEnd: Int
        for _ in 0..<blockCount {
            actualEnd = actualStart + 8
            let actualBytes = Array(array[actualStart..<actualEnd])
            addressary.append(Int.fromByteArray(actualBytes))
            actualStart = actualEnd
        }
        let extensibleHashing = ExtensibleHashing(fileName: fileName, blockFactor: blockFactor, addressary: addressary, blockCount: blockCount, depth: depth)
        
        return extensibleHashing
    }
    
    static func instantiate() -> ExtensibleHashing {
        return ExtensibleHashing(fileName: "", blockFactor: 0) // Dummy method 
    }
    
    
}
