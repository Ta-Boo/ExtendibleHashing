//
//  ExtendibleHashing.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

func debug(_ logger: Bool, _ text: String) {
    if logger {
        print(text)
    }
}

final class ExtensibleHashing<T> where  T: Hashable, T:Storable {
    private var fileName: String
    var blockFactor: Int
    var addressary: [BlockInfo] = []
    var depth = 1
    var blockCount = 0
    let configFile: FileHandle
    let dataFile: FileHandle
    let logger = false
    
    //MARK: Public interface 🔓🔓🔓
    
    //Initial constructor
    init(fileName: String, blockFactor: Int, delete: Bool = true) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        let filePath = FileManager.path(to: "\(fileName).hsh")
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        
        if delete {
            try? FileManager.default.removeItem(atPath: filePath)
            try? FileManager.default.removeItem(atPath: configFilePath)
        }
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: configFilePath, contents: nil, attributes: nil)
            
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            
            addressary.append(BlockInfo(address: addBlock(), neigbourAddress: -1, recordsCount: 0, depth: 1))
            addressary.append(BlockInfo(address: addBlock(), neigbourAddress: -1, recordsCount: 0, depth: 1))
        } else {
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            load()
        }
    }
    
    // Loader Constructor
    internal init(fileName: String, blockFactor: Int, addressary: [BlockInfo] = [], blockCount: Int, depth: Int) {
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
    
    public func add(_ element: T) {
        var inProgress = true
        debug(logger, "💉💉💉Inserting: \(element.name) - \(element.hash.toDecimal(depth: 16)) hash: \(element.hash.desc) key: \(element.hash.toDecimal(depth: depth)) 💉💉💉")
        
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            dataFile.seek(toFileOffset: UInt64(blockInfo.address))
            
            let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            if block.isFull {
                if depth == block.depth {
                    expandAddressary()
                    depth += 1
                    debug(logger, "🔥🔥🔥 depth updated: \(depth)  🔥🔥🔥")
                }
                debug(logger, "❌❌❌ splitting \(blockInfo.address) because of : \(element.name) - \(element.hash.toDecimal(depth: 8)) ❌❌❌")
                split(block, at: blockInfo.address)
                
            } else {
                block.add(element)
                block.save(with: dataFile, at: blockInfo.address)
                debug(logger, "💉✅💉 inserted: \(element.name) - \(element.hash.toDecimal(depth: 8))  hash:  \(element.hash.desc)   partialHash:  \(element.hash.toDecimal(depth: depth)) at  \(blockInfo) 💉✅💉")
                inProgress = false
            }
        }
    }
    
    public func find(_ element: T) -> T? {
        let block = getBlock(by: element)
        let result = block.records.first{ $0.equals(to: element)}
        return result
    }
    
    public func delete(_ element: T) {
        debug(logger, "🗑🗑🗑 deleting \(element.desc) 🗑🗑🗑")
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        let neighbourBlockInfo = addressary.first(where: { $0.address == blockInfo.neigbourAddress })
//        print(blockInfo.desc)
        let block = getBlock(by: blockInfo.address)
        if !block.records.contains(where: { $0.equals(to: element) }) {
            fatalError("You are trying to delete an element, which is not present in the file!")
        }
        block.delete(element)
        if blockInfo.recordsCount + 3 == blockFactor {
            
        }
        block.save(with: dataFile, at: blockInfo.address)
        
//        if (addressary.firstIndex(where: { $0.})! != 0) {
//
//        }
        //        block
    }
    
    func merge(block: Block<T>, to: Block<T>) {
        
    }
    
    func addToBlock(element: T, block: Block<T>) {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        block.add(element)
        block.save(with: dataFile, at: blockInfo.address)
        for (index, loopBlock) in addressary.enumerated() {
            if loopBlock.address == blockInfo.address {
                addressary[index].recordsCount += 1
            }
            
        }
    }
    
    func deleteFromBlock(_ element: T, block: Block<T>) {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        block.delete(element)
        for (index, loopBlock) in addressary.enumerated() {
            if loopBlock.address == blockInfo.address {
                addressary[index].recordsCount -= 1
            }
            
        }
    }
    
    
    private func expandAddressary() {
        var newAdressary: [BlockInfo] = []
        for blockInfo in addressary {
            newAdressary.append(blockInfo)
            newAdressary.append(blockInfo)
        }
        self.addressary = newAdressary
    }
    
    
    private func split(_ block: Block<T>, at oldAddress: Int){
        block.depth += 1
        
        let newAddress = addBlock(block.depth)
        reAdress(from: oldAddress, to: newAddress, depth: block.depth)
        
        let newBlock = getBlock(by: newAddress)
        let newBlockIndex = addressary.firstIndex { $0.address == newAddress }!
        let oldBlockIndex = addressary.firstIndex { $0.address == oldAddress }!
        
        for index in (0..<block.validCount).reversed() {
            let record = block.records[index]
            if record.hash.isSet(block.depth - 1) {
                debug(logger, "🚡🚡🚡 Moving Record \(record.name) - \(record.hash.toDecimal(depth: 8)) = hash:  \(record.hash.desc) value: \(record.hash.toDecimal(depth: depth)) from blockIndex:  \(oldBlockIndex)  at address: \(oldAddress) to blockIndex:  \(newBlockIndex) address: \(newAddress) 🚡🚡🚡")
                
//                newBlock.add(record)
                addToBlock(element: record, block: newBlock)
//                block.delete(record)
                deleteFromBlock(record, block: block)
//                block.records[index] = block.records[block.validCount-1]
//                block.validCount -= 1
            }
        }
        newBlock.save(with: dataFile, at: newAddress)
        block.save(with: dataFile, at: oldAddress)
    }
    
   
    private func addBlock(_ depth: Int = 1) -> Int {
        let address = try! dataFile.seekToEnd()
        let block = Block<T>(blockFactor: blockFactor, depth: depth)
        dataFile.write(Data(block.toByteArray()))
        blockCount += 1
        return Int(address) //WARNING: Be careful about cutting ❗️
    }
    
    private func getBlock(by element: T) -> Block<T> {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        dataFile.seek(toFileOffset: UInt64(blockInfo.address))
        
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
    
    private func reAdress(from old: Int, to new: Int, depth: Int) {
        let from = addressary.firstIndex { $0.address == old }!
        let count = addressary.filter{ $0.address == old }.count
        let range = (from + count/2)..<(from + count)
        
        //remove old neighbourhood
        for oldNeighbour in addressary.filter({ $0.neigbourAddress == old })  {
            oldNeighbour.neigbourAddress = -1
        }
        
        //set up new neighbourhood
        for i in range {
            addressary[i] = BlockInfo(address: new, neigbourAddress: old, recordsCount: 0, depth: depth)
        }
        addressary[from].neigbourAddress = new
        var print = ""
        for adress in addressary {
            print.append(adress.desc)
        }
        debug(logger, "📭📭📭 Changed addresses: \(print) \n📭📭📭")
    }
    
    func save() {
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
    
    func printState(headerOnly: Bool = false) {
        
        var addressaryPrint = ""
        for adress in addressary {
            addressaryPrint.append(adress.desc)
        }
        var result = """
                    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    FileDepth: \(depth)
                    blockFactor: \(blockFactor)
                    addressary: \(addressaryPrint)
                    blockCount: \(blockCount)
                    - - - - - - - - - - - - - - - - - - - - - - -
                    """
        if headerOnly {
            result.append("\n")
            result.append("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")
            print(result)
            return
        }
        for i in 0..<blockCount {
            try! dataFile.seek(toOffset: UInt64(Block<T>.instantiate(blockFactor).byteSize * i))
            let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block =  Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            result.append("\n\t Block(\(UInt64(Block<T>.instantiate(blockFactor).byteSize * i))):\n")
            result.append(block.toString())
        }
        result.append("\n")
        result.append("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")
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
        
        var addressary: [BlockInfo] = []
        var actualStart = 32
        var actualEnd: Int
        for _ in 0..<addressarySize {
            actualEnd = actualStart + 32
            let actualBytes = Array(array[actualStart..<actualEnd])
            addressary.append(BlockInfo().fromByteArray(array: actualBytes))
            actualStart = actualEnd
        }
        let extensibleHashing = ExtensibleHashing(fileName: fileName, blockFactor: blockFactor, addressary: addressary, blockCount: blockCount, depth: depth)
        
        return extensibleHashing
    }
    
    static func instantiate() -> ExtensibleHashing {
        return ExtensibleHashing(fileName: "", blockFactor: 0) // Dummy method 
    }
    
    
}
