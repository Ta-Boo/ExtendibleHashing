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
    let configFile: FileHandle
    let dataFile: FileHandle
    let logger = true
    
    //MARK: Public interface 🔓🔓🔓
    
    //Initial constructor
    init(fileName: String, blockFactor: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        let filePath = FileManager.path(to: "\(fileName).hsh")
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        
        try? FileManager.default.removeItem(atPath: filePath)
        try? FileManager.default.removeItem(atPath: configFilePath)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: configFilePath, contents: nil, attributes: nil)
            
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            
            addressary.append(addBlock())
            addressary.append(addBlock())
        } else {
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            load()
            //        printState()
        }
    }
    
    // Loader Constructor
    internal init(fileName: String, blockFactor: Int, addressary: [Int] = [], blockCount: Int, depth: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        self.addressary = addressary
        self.blockCount = blockCount
        self.depth = depth
        let filePath = FileManager.path(to: "\(fileName).hsh")
        self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
        
    }
    
    func add(_ element: T) {
        var inProgress = true
        if logger {
            print("💉💉💉Inserting: \(element.name) - ",element.hash.toDecimal(depth: 8), "hash:", element.hash.desc, "   partialHash:", element.hash.toDecimal(depth: depth),"💉💉💉")
        }
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let address = addressary[hash]
            dataFile.seek(toFileOffset: UInt64(address))
            
            let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
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
                block.save(with: dataFile, at: address)
                if logger {
                    print("✅✅✅✅✅inserted: \(element.name) - ",element.hash.toDecimal(depth: 8), "hash:", element.hash.desc, "   partialHash:", element.hash.toDecimal(depth: depth), "at", address, "✅✅✅✅✅")
                }
                inProgress = false
            }
        }
        save()
        //        printState()
        
    }
    
    func find(_ element: T) -> T? {
        let block = getBlock(by: element)
        let result = block.records.first{ $0.equals(to: element)}
        return result
    }
    
    private func split(_ block: Block<T>, address: Int){
        block.depth += 1
        
        let newAddress = addBlock(block.depth)
        reAdress(from: address,to: newAddress)
        
        let newBlock = getBlock(by: newAddress)
        let blockIndex = addressary.firstIndex { $0 == newAddress }!
        
        for index in 0..<block.validCount {
            let record = block.records[index]
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
        newBlock.save(with: dataFile, at: newAddress)
        block.save(with: dataFile, at: address)
    }
    
    private func addBlock(_ depth: Int = 1) -> Int {
        print(dataFile.offsetInFile)
        let address = try! dataFile.seekToEnd()
        print(dataFile.offsetInFile)
        
        let block = Block<T>(blockFactor: blockFactor, depth: depth)
        dataFile.write(Data(block.toByteArray()))
        //        dataFile.closeFile()
        blockCount += 1
        return Int(address) //WARNING: Be careful about cutting ❗️
    }
    
    private func getBlock(by element: T) -> Block<T> {
        let hash = element.hash.toDecimal(depth: depth)
        let address = UInt64(addressary[hash])
        dataFile.seek(toFileOffset: address)
        
        let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
        let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
        return block
    }
    
    private func getBlock(by address: Int) -> Block<T> {
        try! dataFile.seek(toOffset: UInt64(address))
        let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
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
        if blockCount == 5 {
            printState()
        }
        configFile.seek(toFileOffset: 0)
        configFile.write(Data(toByteArray()))
        //        configFile.closeFile()
    }
    
    private func load() {
        let data = configFile.readDataToEndOfFile()
        let bytes = [UInt8](data)
        let loaded = fromByteArray(array: bytes)
        copy(other: loaded)
        //        configFile.closeFile()
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
        var result = """
                    *******************************************************************************************************************
                    FileDepth: \(depth)
                    blockFactor: \(blockFactor)
                    addressary: \(addressary)
                    blockCount: \(blockCount)
                    ----------------------
                    """
        for i in 0..<blockCount {
            try! dataFile.seek(toOffset: UInt64(Block<T>.instantiate(blockFactor).byteSize * i))
            let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
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
