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
    var freeAddresses: [Int] = []
    var depth = 1
    var blockCount = 0
    let configFile: FileHandle
    let dataFile: FileHandle
    let logger: Bool
    
    //MARK: Public interface 🔓🔓🔓
    
    //Initial constructor
    init(fileName: String, blockFactor: Int, delete: Bool = true, logger: Bool = false) {
        self.logger = logger
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
    internal init(fileName: String, blockFactor: Int, addressary: [BlockInfo] = [], freeAddresses: [Int], blockCount: Int, depth: Int) {
        self.fileName = fileName
        self.blockFactor = blockFactor
        self.addressary = addressary
        self.blockCount = blockCount
        self.depth = depth
        let filePath = FileManager.path(to: "\(fileName).hsh")
        self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
        self.logger = false
        self.freeAddresses = freeAddresses
    }
    
    public func add(_ element: T) {
        var inProgress = true
        debug(logger, "💉💉💉Inserting: \(element.name) - \(element.hash.toDecimal(depth: 8)) hash: \(element.hash.desc) key: \(element.hash.toDecimal(depth: depth)) 💉💉💉")
        
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            let block = getBlock(by: blockInfo.address)
            if block.isFull {
                if depth == block.depth {
                    expandAddressary()
                    depth += 1
                    debug(logger, "🔥🔥🔥 depth updated: \(depth)  🔥🔥🔥")
                }
                debug(logger, "❌❌❌ splitting \(blockInfo.address) because of : \(element.name) - \(element.hash.toDecimal(depth: 8)) ❌❌❌")
                split(block, at: blockInfo.address)
                
            } else {
                addToBlock(element: element, block: block, at: blockInfo.address)
                block.save(with: dataFile, at: blockInfo.address)
                //                block.add(element)
                //                block.save(with: dataFile, at: blockInfo.address)
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
        var blockInfo = addressary[hash]
        let block = getBlock(by: blockInfo.address)
        let secondBlock = getBlock(by: blockInfo.neigbourAddress)
        if !block.records.contains(where: { $0.equals(to: element) }) {
            fatalError("You are trying to delete an element, which is not present in the file!")
        }
        
        if blockInfo.neigbourAddress == -1 {
            block.delete(element)
            block.save(with: dataFile, at: blockInfo.address)
            return
        }
        
        let neighbourBlockInfo = addressary.first(where: { $0.address == blockInfo.neigbourAddress })!
        printState(headerOnly: false)
        deleteFromBlock(element, block: block, at: blockInfo.address)
        printState(headerOnly: false)
        //        block.delete(element)
        blockInfo = addressary[hash]
        if blockInfo.recordsCount + neighbourBlockInfo.recordsCount == blockFactor {
            if blockInfo.neigbourAddress != neighbourBlockInfo.address {fatalError()}
            if blockInfo.address != neighbourBlockInfo.neigbourAddress {fatalError()}
            if blockInfo.address == neighbourBlockInfo.address {fatalError()}
            mergeBlocks(first: block,
                        firstAddress: blockInfo.address,
                        second: secondBlock,
                        secondAddress: blockInfo.neigbourAddress)
            //            fatalError("merging")
        }
        block.save(with: dataFile, at: blockInfo.address)
        secondBlock.save(with: dataFile, at: blockInfo.neigbourAddress)
    }
    
    func mergeBlocks(first: Block<T>, firstAddress: Int, second: Block<T>, secondAddress: Int) {
        let baseBlock = firstAddress < secondAddress ? first : second
        let secondaryBlock = firstAddress > secondAddress ? first : second
        let baseAddress = min(firstAddress, secondAddress)
        let secondaryAddress = max(firstAddress, secondAddress)
        
        let records = Array(secondaryBlock.records.prefix(secondaryBlock.validCount))
        
        let index = freeAddresses.firstIndex(where: { $0 < secondaryAddress }) ?? 0
        freeAddresses.insert(secondaryAddress, at: index)

        
        for record in records {
            addToBlock(element: record, block: baseBlock, at: baseAddress)
        }
        
        addressary[addressary.firstIndex(where: { $0.address == baseAddress})!].neigbourAddress = -1
        
        addressary.replaceReferences(toBeReplaced: addressary.firstIndex(where: { $0.address == secondaryAddress})!,
                                     with: addressary.firstIndex(where: { $0.address == baseAddress})!)
        baseBlock.depth -= 1
        baseBlock.save(with: dataFile, at: baseAddress)
        if !addressary.uniqueReferences.contains(where: { $0.depth == (baseBlock.depth + 1) }) {
//            fatalError("SHould shrink")
                        shrinkAddressary()
        }
        
        //        if addressary.contains(where: { $0.depth > baseBlock.depth }) {
        //
        //        } else {
        //            let ahoj = addressary.uniqueReferences.filter({ $0.depth ==  (baseBlock.depth)}).count
        //            let count = addressary.filter({ $0.depth ==  (baseBlock.depth)}).count
        //            fatalError("addresary should shrink: \(count)")
        //        }
    }
    
    func shrinkAddressary() {
        depth -= 1
        var changes: [Int] = []
        var previuousAddress = -1
        for i in 0..<addressary.count {
            let actualAddress = addressary[i].address
            if previuousAddress != actualAddress {
                changes.append(i)
            }
            previuousAddress = actualAddress
        }
        var ranges: [Range<Int>] = []
        for (i, change) in changes.enumerated() {
            let start = change
            let end = i < (changes.count - 1) ? changes[i + 1] : addressary.count
            let size = (Double(end - start) / 2.0).rounded(.up)
            ranges.append((start + Int(size))..<end)
        }
        for range in ranges.reversed() {
            for i in range.reversed() {
                addressary.remove(at: i)
            }
        }
        
    }
    
    func addToBlock(element: T, block: Block<T>, at address: Int) {
        block.add(element)
        addressary[addressary.firstIndex(where: { $0.address == address })!].recordsCount += 1
    }
    
    func deleteFromBlock(_ element: T, block: Block<T>, at address: Int) {
        block.delete(element)
        //        printState(headerOnly: false)
        addressary[addressary.firstIndex(where: { $0.address == address })!].recordsCount -= 1
        //        printState(headerOnly: false)
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
        
        let newRecords = block.records.filter{ $0.hash.isSet(block.depth - 1)}
        
        for record in newRecords {
            debug(logger, "🚡🚡🚡 Moving Record \(record.name) - \(record.hash.toDecimal(depth: 8)) = hash:  \(record.hash.desc) value: \(record.hash.toDecimal(depth: depth)) from blockIndex:  \(oldBlockIndex)  at address: \(oldAddress) to blockIndex:  \(newBlockIndex) address: \(newAddress) 🚡🚡🚡")
            addToBlock(element: record, block: newBlock, at: newAddress)
            deleteFromBlock(record, block: block, at: oldAddress)
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
        let blockInfo = BlockInfo(address: new, neigbourAddress: old, recordsCount: 0, depth: depth) // To keep reference dependency in addressary
        for i in range {
            addressary[i] = blockInfo
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
        let debugFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(fileName)-DEBUG.hsh")
        
        
        var addressaryPrint = ""
        for adress in addressary {
            addressaryPrint.append(adress.desc)
        }
        var result = """
                    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    FileDepth: \(depth)
                    blockFactor: \(blockFactor)
                    freeAddresses: \(freeAddresses)
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
        //        print(result)
        try! result.write(to: debugFilePath, atomically: true, encoding: .utf8)
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
        var previousBlockInfo = BlockInfo(address: -11, neigbourAddress: -11, recordsCount: -11, depth: -11)
        for _ in 0..<addressarySize {
            actualEnd = actualStart + 32
            let actualBytes = Array(array[actualStart..<actualEnd])
            let actualBlockInfo = BlockInfo().fromByteArray(array: actualBytes)
            if actualBlockInfo.address != previousBlockInfo.address {
                previousBlockInfo = actualBlockInfo // one reference for each block
                addressary.append(actualBlockInfo)
            } else {
                addressary.append(previousBlockInfo)
            }
            actualStart = actualEnd
        }
        let extensibleHashing = ExtensibleHashing(fileName: fileName,
                                                  blockFactor: blockFactor,
                                                  addressary: addressary,
                                                  freeAddresses: [], //FIXME: ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
                                                  blockCount: blockCount,
                                                  depth: depth)
        
        return extensibleHashing
    }
    
    static func instantiate() -> ExtensibleHashing {
        return ExtensibleHashing(fileName: "", blockFactor: 0) // Dummy method 
    }
    
    
}
