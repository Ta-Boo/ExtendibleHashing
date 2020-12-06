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

final class ExtensibleHashing<T> where  T: Hashable, T:Storable, T: Property {
    private var fileName: String
    var blockFactor: Int
    var addressary: [BlockInfo] = []
    var freeAddresses: [Int] = []
    var overflowingAddressary: [BlockInfo] = []
    var depth = 1
    var blockCount = 0
    let configFile: FileHandle
    let dataFile: FileHandle
    let overflowDataFile: FileHandle
    let logger: Bool
    let maxSize = 800
    
    
    //Initial constructor
    init(fileName: String, blockFactor: Int, delete: Bool = true, logger: Bool = false) {
        self.logger = logger
        self.fileName = fileName
        self.blockFactor = blockFactor
        let filePath = FileManager.path(to: "\(fileName).hsh")
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        let overflowFilePath = FileManager.path(to: "\(fileName)-overflow.hsh")
        
        if delete {
            try? FileManager.default.removeItem(atPath: filePath)
            try? FileManager.default.removeItem(atPath: configFilePath)
            try? FileManager.default.removeItem(atPath: overflowFilePath)
        }
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: configFilePath, contents: nil, attributes: nil)
            FileManager.default.createFile(atPath: overflowFilePath, contents: nil, attributes: nil)
            
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            self.overflowDataFile = FileHandle(forUpdatingAtPath: overflowFilePath)!
            
            addressary.append(BlockInfo(address: addBlock(), neigbourAddress: -1, recordsCount: 0, depth: 1, nextBlockAddress: -1))
            addressary.append(BlockInfo(address: addBlock(), neigbourAddress: -1, recordsCount: 0, depth: 1, nextBlockAddress: -1))
        } else {
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            self.overflowDataFile = FileHandle(forUpdatingAtPath: overflowFilePath)!
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
        let overflowFilePath = FileManager.path(to: "\(fileName)-overflow.hsh")
        self.overflowDataFile = FileHandle(forUpdatingAtPath: overflowFilePath)!
        self.logger = false
        self.freeAddresses = freeAddresses
    }
    
    //MARK: INSERT
    public func add(_ element: T) {
        var inProgress = true
        debug(logger, "💉💉💉Inserting: \(element.name) - \(element.hash.toRealDecimal()) hash: \(element.hash.desc) key: \(element.hash.toDecimal(depth: depth)) 💉💉💉")
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            let block = loadBlock(by: blockInfo.address, from: dataFile)
            if block.isFull {
                if block.depth == maxSize {
                    addToOverflowing(element, starting: block, at: blockInfo.address)
                    return
                }
                if depth == block.depth {
                    expandAddressary()
                    depth += 1
                    debug(logger, "🔥🔥🔥 depth updated: \(depth)  🔥🔥🔥")
                }
                debug(logger, "❌❌❌ splitting \(blockInfo.address) because of : \(element.name) - \(element.hash.toRealDecimal()) ❌❌❌")
                split(block, at: blockInfo.address)
                
            } else {
                addToBlock(element: element, block: block, at: blockInfo.address)
                block.save(with: dataFile, at: blockInfo.address)
                debug(logger, "💉✅💉 inserted: \(element.name) - \(element.hash.toRealDecimal())  hash:  \(element.hash.desc)   partialHash:  \(element.hash.toDecimal(depth: depth)) at  \(blockInfo) 💉✅💉")
                inProgress = false
            }
        }
    }
    
    private func addToOverflowing(_ element: T, starting firstBlock: Block<T>, at address: Int) {
        let firstBlock = addressary.first(where: {$0.address == address})!
        if firstBlock.nextBlockAddress == -1 {
            let addressedBlock = addBlockToOverFlow()
            addressary.first(where: {$0.address == address})!.nextBlockAddress = addressedBlock.address
            addToOverFlowingBlock(element: element, block: addressedBlock.block, at: addressedBlock.address)
            addressedBlock.block.save(with: overflowDataFile, at: addressedBlock.address )
            
        } else {
            var inserted = false
            var actualBlockInfo = overflowingAddressary.first(where: {$0.address == firstBlock.nextBlockAddress})!
            while !inserted {
                if actualBlockInfo.recordsCount < blockFactor {
                    inserted = true
                    let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile)
                    addToOverFlowingBlock(element: element, block: block, at: actualBlockInfo.address)
                    block.save(with: overflowDataFile, at: actualBlockInfo.address)
                } else {
                    if actualBlockInfo.nextBlockAddress == -1 {
                        inserted = true
                        let addressedBlock = addBlockToOverFlow()
                        overflowingAddressary.first(where: {$0.address == actualBlockInfo.address})!.nextBlockAddress = addressedBlock.address
                        addToOverFlowingBlock(element: element, block: addressedBlock.block, at: addressedBlock.address)
                        addressedBlock.block.save(with: overflowDataFile, at: addressedBlock.address )
                    } else {
                        actualBlockInfo = overflowingAddressary.first(where: {$0.address == actualBlockInfo.nextBlockAddress})!
                    }
                }
            }
        }
    }
    
    //MARK: FIND
    public func find(_ element: T) -> T? {
        debug(logger, "🔍🔍🔍 Looking for \(element.name) - \(element.hash.toRealDecimal()) hash: \(element.hash.desc) key: \(element.hash.toDecimal(depth: depth))  🔍🔍🔍")
        let block = loadBlock(by: element, from: dataFile)
        let result = block.records.first{ $0.equals(to: element)}
        if result == nil {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            if blockInfo.nextBlockAddress == -1 {
                return nil
            }
            var actualBlockInfo = overflowingAddressary.first(where: { $0.address == blockInfo.nextBlockAddress})!
            while true {
                let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile)
                let element = block.records.first{ $0.equals(to: element)}
                if element == nil {
                    if actualBlockInfo.nextBlockAddress == -1 {
                        return nil
                    }
                    actualBlockInfo = overflowingAddressary.first(where: { $0.address == actualBlockInfo.nextBlockAddress})!
                } else {
                    return element
                }
            }
        }
        return result
    }
    
    //MARK: DELETE
    public func delete(_ element: T) {
        //TODO: shrinking file ❗️
        printState()
        let hash = element.hash.toDecimal(depth: depth)
        var blockInfo = addressary[hash]
        var block = loadBlock(by: blockInfo.address, from: dataFile)  //🗄🗄🗄🗄🗄🗄
        debug(logger, "🗑🗑🗑 deleting \(element.desc) from block: \(blockInfo.address) \n🗑🗑🗑")
       
        //If no data found, seek for element in overflowing
        if !block.records.contains(where: { $0.equals(to: element) }) {
            if deleteFromOverflowing(element) {
                fatalError("You are trying to delete an element, which is not present in the file!")
            }
            fatalError("Not found")
        }
        
        //If there is no neighbour, simply remove record and save
        if blockInfo.neigbourAddress == -1 {
            deleteFromBlock(element, block: block, at: blockInfo.address)
            block.save(with: dataFile, at: blockInfo.address) //🗄🗄🗄🗄🗄🗄
            return
        }
        
        
        var neighbourBlockInfo = addressary.first(where: { $0.address == blockInfo.neigbourAddress })!
        deleteFromBlock(element, block: block, at: blockInfo.address)
        
        //Save block and return if merging is not possible
        if blockInfo.recordsCount + neighbourBlockInfo.recordsCount > blockFactor {
            block.save(with: dataFile, at: blockInfo.address) //🗄🗄🗄🗄🗄🗄 once durring method call
            return
        }
        //Merging cycle
        while blockInfo.recordsCount + neighbourBlockInfo.recordsCount <= blockFactor {
            let secondBlock = loadBlock(by: blockInfo.neigbourAddress, from: dataFile) //🗄🗄🗄🗄🗄🗄
            printState()

            let addressedBlock = mergeBlocks(first: block,
                        firstAddress: blockInfo.address,
                        second: secondBlock,
                        secondAddress: blockInfo.neigbourAddress)//🗄🗄🗄🗄🗄🗄 once durring method call
            block = addressedBlock.block
            printState()
            recalculateNeighbourhoods()
            printState()

            block.save(with: dataFile, at: addressedBlock.address) // maybe useless
            blockInfo = addressary.first(where: { $0.address == addressedBlock.address})!
            if blockInfo.neigbourAddress == -1 {
                return
            }
            neighbourBlockInfo = addressary.first(where: { $0.address == blockInfo.neigbourAddress})!
        }
//        block.save(with: dataFile, at: addressedBlock.address)

    }
    
    private func deleteFromOverflowing(_ element: T) -> Bool {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        if blockInfo.nextBlockAddress == -1 {
            return false
        }
        var actualBlockInfo = overflowingAddressary.first(where: { $0.address == blockInfo.nextBlockAddress})!
        while true {
            let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile)
            let element = block.records.first{ $0.equals(to: element)}
            if element == nil {
                if actualBlockInfo.nextBlockAddress == -1 {
                    return false
                }
                actualBlockInfo = overflowingAddressary.first(where: { $0.address == actualBlockInfo.nextBlockAddress})!
            } else {
                //delete from block an merge
                deleteFromOverFlowingBlock(element: element!, block: block, at: actualBlockInfo.address)
                mergeOverflowingBlocks(block: AddressedBlock(address: actualBlockInfo.address, block: block), startingInfo: blockInfo)
                return true
            }
        }
    }
    
    private func mergeOverflowingBlocks(block: AddressedBlock<T>, startingInfo: BlockInfo) {
        fatalError("Element is in overflowing file")
        var freeCount = 0
        var actualInfo = startingInfo
        let freeCountInMainFile = blockFactor - startingInfo.recordsCount
        var blockCount = 1
        while true {
            freeCount += (blockFactor - actualInfo.recordsCount)
            if actualInfo.nextBlockAddress == -1 {
                break
            }
            blockCount += 1
            actualInfo = overflowingAddressary.first(where: { $0.address == actualInfo.nextBlockAddress})!
        }
        if freeCount == freeCountInMainFile {
            //
        }
        // po celej trase zistim volne miesta. Ak cislo % blockfactor == 0  prehodim  od konca zacnem prehadzovat zaznamy na prve pozicie ulozim blok a zmensim subor
    }

    //MARK: OVERFLOW HELPERS
    private func addToOverFlowingBlock(element: T, block: Block<T>, at address: Int) {
        block.add(element)
        overflowingAddressary.first(where: { $0.address == address })!.recordsCount += 1
    }
    
    private func deleteFromOverFlowingBlock(element: T, block: Block<T>, at address: Int) {
        block.delete(element)
        overflowingAddressary.first(where: { $0.address == address })!.recordsCount -= 1
    }
    
    private func addBlockToOverFlow() -> AddressedBlock<T> {
        let address = Int(overflowDataFile.seekToEndOfFile()) //WARNING: Be careful about cutting ❗️
        overflowingAddressary.append(BlockInfo(address: address, neigbourAddress: -1, recordsCount: 0, depth: 0, nextBlockAddress: -1))
        let block = Block<T>(blockFactor: blockFactor, depth: 0)
        return AddressedBlock(address: address, block: block)
    }
    
    
    //MARK: HELPERS
    private func addToBlock(element: T, block: Block<T>, at address: Int) {
        block.add(element)
        addressary[addressary.firstIndex(where: { $0.address == address })!].recordsCount += 1
    }
    
    private func deleteFromBlock(_ element: T, block: Block<T>, at address: Int) {
        block.delete(element)
        addressary[addressary.firstIndex(where: { $0.address == address })!].recordsCount -= 1
    }
    
    private func addBlock(_ depth: Int = 1) -> Int {
        let address = freeAddresses.popLast() ?? Int(try! dataFile.seekToEnd()) //WARNING: Be careful about cutting ❗️
        let block = Block<T>(blockFactor: blockFactor, depth: depth)
        dataFile.write(Data(block.toByteArray()))
        blockCount += 1
        return address
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
        addressary.first(where: {$0.address == oldAddress})!.depth += 1
        
        let newAddress = addBlock(block.depth)
        reAdress(from: oldAddress, to: newAddress, depth: block.depth)
        
        let newBlock = loadBlock(by: newAddress, from: dataFile)
        let newBlockIndex = addressary.firstIndex { $0.address == newAddress }!
        let oldBlockIndex = addressary.firstIndex { $0.address == oldAddress }!
        
        let newRecords = block.records.filter{ $0.hash.isSetReversed(block.depth - 1)}
        
        for record in newRecords {
            debug(logger, "🚡🚡🚡 Moving Record \(record.name) - \(record.hash.toRealDecimal()) = hash:  \(record.hash.desc) value: \(record.hash.toDecimal(depth: depth)) from blockIndex:  \(oldBlockIndex)  at address: \(oldAddress) to blockIndex:  \(newBlockIndex) address: \(newAddress) 🚡🚡🚡")
            addToBlock(element: record, block: newBlock, at: newAddress)
            deleteFromBlock(record, block: block, at: oldAddress)
        }
        
        newBlock.save(with: dataFile, at: newAddress)
        block.save(with: dataFile, at: oldAddress)
    }
    
    private func shrinkAddressary() {
        //TODO: RECALCULATE NEIGHBOURS
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
        debug(logger, "📭📭📭 Shrinked addressary 📭📭📭")
        var result = ""
        for adress in addressary {
            result.append(adress.desc)
        }
        debug(logger, result)
    }
    
    private func mergeBlocks(first: Block<T>, firstAddress: Int, second: Block<T>, secondAddress: Int) -> AddressedBlock<T> {
        blockCount -= 1
        let baseBlock = firstAddress < secondAddress ? first : second
        let secondaryBlock = firstAddress > secondAddress ? first : second
        let baseAddress = min(firstAddress, secondAddress)
        let secondaryAddress = max(firstAddress, secondAddress)
        
//        let baseBlock = first
//        let secondaryBlock = second
//        let baseAddress = firstAddress
//        let secondaryAddress = secondAddress
        
        debug(logger, "🍡🍡🍡Merging block(\(secondaryAddress)) into block(\(baseAddress)🍡🍡🍡")
        
        
        let records = Array(secondaryBlock.records.prefix(secondaryBlock.validCount))
        
        let index = freeAddresses.insertionIndex(of: secondaryAddress)
        freeAddresses.insert(secondaryAddress, at: index)
        
        
        for record in records {
            debug(logger, "🚡🚡🚡 Moving Record \(record.hash.toRealDecimal()), hash:  \(record.hash.desc) from block(\(secondaryAddress)) to block(\(baseAddress) 🚡🚡🚡")
            addToBlock(element: record, block: baseBlock, at: baseAddress)
            deleteFromBlock(record, block: secondaryBlock, at: secondaryAddress)
        }
        let addressaryIndex = addressary.firstIndex(where: { $0.address == baseAddress})!
        addressary[addressaryIndex].neigbourAddress = -1
        addressary[addressaryIndex].depth -= 1
        baseBlock.depth -= 1
        
        addressary.replaceReferences(toBeReplaced: addressary.firstIndex(where: { $0.address == secondaryAddress})!,
                                     with: addressary.firstIndex(where: { $0.address == baseAddress})!)
        baseBlock.save(with: dataFile, at: baseAddress)//🗄🗄🗄🗄🗄🗄
        secondaryBlock.save(with: dataFile, at: secondaryAddress)//🗄🗄🗄🗄🗄🗄
        if !addressary.uniqueReferences.contains(where: { $0.depth == (baseBlock.depth + 1) }) {
            shrinkAddressary()
        }
        return AddressedBlock(address: baseAddress, block: baseBlock)
    }
    
    private func recalculateNeighbourhoods() {
        if addressary.count <= 2 {
            return
        }
        for (index, blockInfo) in addressary.enumerated() {
            if index % 2 == 0 {
                if blockInfo !== addressary[index + 1] {
                    blockInfo.neigbourAddress = addressary[index + 1].address
                }
                
            } else {
                if blockInfo !== addressary[index - 1] {
                    blockInfo.neigbourAddress = addressary[index - 1].address
                }
            }
        }
    }
    
    private func loadBlock(by element: T,  from dataFile: FileHandle) -> Block<T> {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        return loadBlock(by: blockInfo.address, from: dataFile)
    }
    
    private func loadBlock(by address: Int, from dataFile: FileHandle) -> Block<T> {
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
        let blockInfo = BlockInfo(address: new, neigbourAddress: old, recordsCount: 0, depth: depth, nextBlockAddress: -1) // To keep reference dependency in addressary
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
    
    //MARK: DEBUGGING  🐞
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
            dataFile.seek(toFileOffset: UInt64(Block<T>.instantiate(blockFactor).byteSize * i))
            let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block =  Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            result.append("\n\t Block(\(UInt64(Block<T>.instantiate(blockFactor).byteSize * i))):\n")
            result.append(block.toString())
        }
        result.append("\n")
        result.append("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n")
        result.append("Overflowing file: \n")
        var overflowingHeader = "Addressary: \n"
        for blockInfo in overflowingAddressary {
            overflowingHeader.append(blockInfo.desc)
        }
        
        for i in 0..<overflowingAddressary.count {
            overflowDataFile.seek(toFileOffset: UInt64(Block<T>.instantiate(blockFactor).byteSize * i))
            let bytes = [UInt8](overflowDataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
            let block =  Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
            overflowingHeader.append("\n\t Block(\(UInt64(Block<T>.instantiate(blockFactor).byteSize * i))):\n")
            overflowingHeader.append(block.toString())
        }
        result.append(overflowingHeader)
        
        try! result.write(to: debugFilePath, atomically: true, encoding: .utf8)
    }
    
}
//MARK: STORING
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
        var previousBlockInfo = BlockInfo(address: -11, neigbourAddress: -11, recordsCount: -11, depth: -11, nextBlockAddress: -11)
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
