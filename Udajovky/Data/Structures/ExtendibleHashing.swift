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
    
    var filePath: String {
        get {
            return FileManager.path(to: "\(fileName).hsh")
        }
    }
    
    var configFilePath: String {
        get {
            return FileManager.path(to: "\(fileName)-config.hsh")
        }
    }

    //MARK: Public interface 🔓🔓🔓
   
    //Initial constructor
    init(fileName: String, blockFactor: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        try! FileManager.default.removeItem(atPath: filePath)
        try! FileManager.default.removeItem(atPath: configFilePath)
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: configFilePath, contents: nil, attributes: nil)
            addressary = [0,0]
            for i in 0...1 {
                addressary[i] = addBlock()
            }
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
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        var inProgress = true
        print("     hash:", element.hash.desc, "   partialHash:", element.hash.toDecimal(depth: depth), "      depth:", depth)
        print("---------------------------------------------------------------------------------------------")
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let address = UInt64(addressary[hash])
            fileHandle.seek(toFileOffset: address)
            
            let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            var block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            
            if block.isFull {
//                print(depth)
//                print(block.depth)
                if depth == block.depth {
                    var newAdressary: [Int] = []
                    for address in addressary {
                        newAdressary.append(address)
                        newAdressary.append(address)
                    }
//                    depth += 1
                    self.addressary = newAdressary
                }
                print("splitting:", element.hash.toDecimal(depth: 16))
                block = split(block, address: address)
                
            } else {
                block.add(element)
                block.save(with: fileHandle, at: address)
                save()
                
                inProgress = false
            }
        }
        
    }
    
    private func split(_ block: Block<T>, address: UInt64) -> Block<T> {
        block.validCount = 0
        block.depth += 1
        depth += 1

        let newAddress = addBlock()
        let indexOfAddress = addressary.firstIndex { $0 == address }!
        let sameAddressCount = addressary.filter{ $0 == address }.count
        readress(from: indexOfAddress, count: sameAddressCount, toAdress: newAddress)
        
        for record in block.records {
            print("rehashing:", record.hash.toDecimal(depth: 16))
            add(record)
        }
        
        return block
    }
    
    private func getBlock(of element: T) -> Block<T> {
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        let hash = element.hash.toDecimal(depth: depth)
        let address = UInt64(addressary[hash])
        fileHandle.seek(toFileOffset: address)
        
        let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
        let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
        return block
    }
    
    private func readress(to address: Int) {
        let from = addressary.firstIndex { $0 == address }!
        let count = addressary.filter{ $0 == address }.count
        let range = (from + count/2)..<(from + count)
        for i in range {
            addressary[i] = address
        }
    }

    private func addBlock(_ depth: Int = 1) -> Int {
        let fileHandle = FileHandle(forWritingAtPath: filePath)!
        let result = fileHandle.seekToEndOfFile()
        let block = Block<T>(blockFactor: blockFactor, depth: depth)
        fileHandle.write(Data(block.toByteArray()))
        fileHandle.closeFile()
        blockCount += 1
        return Int(result) //WARNING: Be careful about cutting ❗️
    }
    
    private func save() {
        let fileHandle = FileHandle(forWritingAtPath: configFilePath)!
        fileHandle.write(Data(toByteArray()))
        fileHandle.closeFile()
    }
    
    private func load() {
        let fileHandle = FileHandle(forReadingAtPath: configFilePath)!
        let data = fileHandle.readDataToEndOfFile()
        let bytes = [UInt8](data)
        let loaded = fromByteArray(array: bytes)
        copy(other: loaded)
        fileHandle.closeFile()
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
        return Property.instantiate().fromByteArray(array: bytes)
    }
    
    func testBlockSave() {
        let block = Block<Property>(blockFactor: 5)
        let fileHandle = FileHandle(forWritingAtPath: filePath)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(Data(block.toByteArray()))
        fileHandle.closeFile()
    }
    
    func testBlockLoad() {
        let fileHandle = FileHandle(forReadingAtPath: filePath)!
        try! fileHandle.seek(toOffset: UInt64(Block<Property>.instantiate(blockFactor).byteSize * 20))
        let data = fileHandle.readData(ofLength: Block<Property>.instantiate(blockFactor).byteSize)
        let bytes = [UInt8](data)
        let result = Block<Property>.instantiate(blockFactor).fromByteArray(array: bytes)
    }
    
}

extension ExtensibleHashing: Storable {
    var desc: String {
        "asd"
    }
    
    var byteSize: Int {
        return 20*2 + 3*8 + 8*addressary.count
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: depth.toByteArray())
        result.append(contentsOf: blockFactor.toByteArray())
        result.append(contentsOf: blockCount.toByteArray())
        result.append(contentsOf: addressary.count.toByteArray())
//        result.append(contentsOf: fileName.toByteArray(length: 20))
        
        for adress in addressary {
            result.append(contentsOf: adress.toByteArray())
        }
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> ExtensibleHashing {
        let depth = Int.fromByteArray(Array(array[0..<8]))
        let blockFactor = Int.fromByteArray(Array(array[8..<16]))
        let blockCount = Int.fromByteArray(Array(array[16..<24]))
        let addressarySize = Int.fromByteArray(Array(array[24..<32]))
//        let fileName = String.fromByteArray(Array(array[24..<64]))
        
        var addressary: [Int] = []
        var actualStart = 32
        var actualEnd: Int
        for _ in 0..<addressarySize {
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
