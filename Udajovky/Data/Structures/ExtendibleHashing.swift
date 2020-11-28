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
    let logger = false
    
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
        if logger {
            print("💉💉💉Inserting: \(element.name) - ",element.hash.toDecimal(depth: 8), "hash:", element.hash.desc, "   partialHash:", element.hash.toDecimal(depth: depth),"💉💉💉")
        }
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let address = addressary[hash]
            fileHandle.seek(toFileOffset: UInt64(address))
            
            let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            if block.isFull {
                if depth == block.depth {
                    var newAdressary: [Int] = []
                    for address in addressary {
                        newAdressary.append(address)
                        newAdressary.append(address)
                    }
                    self.addressary = newAdressary
                    depth += 1
                    if logger {
                        print("🔥🔥🔥 depth updated:", depth, "🔥🔥🔥")
                    }
                }
                if logger {
                    print("❌❌❌❌splitting ",address,"because of : \(element.name) - ", element.hash.toDecimal(depth: 8), "❌❌❌❌")
                }
                split(block, address: address) 
                
            } else {
                block.add(element)
                block.save(with: fileHandle, at: address)
                save()
                if logger {
                    print("✅✅✅✅✅inserted: \(element.name) - ",element.hash.toDecimal(depth: 8), "hash:", element.hash.desc, "   partialHash:", element.hash.toDecimal(depth: depth), "at", address, "✅✅✅✅✅")
                }
                inProgress = false
            }
        }
        printState()
        
    }
    
    func find(_ element: T) -> T? {
        let block = getBlock(by: element)
        let result = block.records.first{ $0.equals(to: element)}
        return result
    }
    
    private func split(_ block: Block<T>, address: Int){
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        block.depth += 1
       
        let newAddress = addBlock(block.depth)
        reAdress(from: address,to: newAddress)
        
        let newBlock = getBlock(by: newAddress)
        let blockIndex = addressary.firstIndex { $0 == newAddress }!
        
        for index in 0..<block.validCount {
            let record = block.records[index]
            let hash = record.hash.desc
            if record.hash.isSet(block.depth - 1) {
                if newBlock.isFull { fatalError() }
                if logger {
                    print(" 🚡🚡🚡 Moving Record \(record.name) - \(record.hash.toDecimal(depth: 8)) = hash:", record.hash.desc, "value:",  record.hash.toDecimal(depth: depth),
                          "from blockIndex:", addressary.firstIndex { $0 == address }!, "at address:",address,
                          "to blockIndex:", blockIndex, "address:" ,newAddress, "🚡🚡🚡")
                }
                newBlock.add(record)
                block.records[index] = block.records[block.validCount-1]
                block.validCount -= 1
            }
        }
        newBlock.save(with: fileHandle, at: newAddress)
        block.save(with: fileHandle, at: address)
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
    
    private func getBlock(by element: T) -> Block<T> {
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        let hash = element.hash.toDecimal(depth: depth)
        let address = UInt64(addressary[hash])
        fileHandle.seek(toFileOffset: address)
        
        let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
        let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
        return block
    }
    
    private func getBlock(by address: Int) -> Block<T> {
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        fileHandle.seek(toFileOffset: UInt64(address))
        let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
        let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
        return block
    }
    
    private func reAdress(from old: Int, to new: Int) {
        let from = addressary.firstIndex { $0 == old }!
        let count = addressary.filter{ $0 == old }.count
        let range = (from + count/2)..<(from + count)
        for i in range {
            addressary[i] = new
        }
        if logger {
            print("📭📭📭reAdressed:",addressary,"📭📭📭")
        }
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
    
    func printState() {
        if !logger { return }
        let fileHandle = FileHandle(forUpdatingAtPath: filePath)!
        var result = """
                    *******************************************************************************************************************
                    FileDepth: \(depth)
                    blockFactor: \(blockFactor)
                    addressary: \(addressary)
                    blockCount: \(blockCount)
                    ----------------------
                    """
        for i in 0..<blockCount {
            try! fileHandle.seek(toOffset: UInt64(Block<T>.instantiate(blockFactor).byteSize * i))
            let bytes = [UInt8](fileHandle.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block =  Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            result.append("\n\t Block(\(UInt64(Block<T>.instantiate(blockFactor).byteSize * i))):\n")
            result.append(block.toString())
        }
        result.append("\n*******************************************************************************************************************")
        print(result)
    }
    
    
    //MARK: Testing  🧪🧪🧪
    
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
