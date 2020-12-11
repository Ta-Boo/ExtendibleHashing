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
    var depth = 1                                   // 1
    var blockFactor: Int                            // 2
    var blockFactorOverflowing: Int                            // 2
    var blockCount = 0                              // 3
    var maxSize: Int                                // 4
    var addressary: [BlockInfo] = []                // 5.1 ,5.2
    var freeAddresses: [Int] = []                   // 6.1, 6.2
    var overflowingAddressary: [BlockInfo] = []     // 7.1, 7.2
    var freeAddressesOverflowing: [Int] = []        // 8.1, 8.2
    let configFile: FileHandle
    let dataFile: FileHandle
    let overflowDataFile: FileHandle
    let logger: Bool
    
    
    //Initial constructor
    init(fileName: String, blockFactor: Int, blockFactorOverflowing: Int, maxDepth: Int = 8, delete: Bool = true, logger: Bool = false) {
        self.logger = logger
        self.fileName = fileName
        self.blockFactor = blockFactor
        self.blockFactorOverflowing = blockFactorOverflowing
        self.maxSize = maxDepth
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
            
            addressary.append(BlockInfo(address: addBlock(), recordsCount: 0, depth: 1, nextBlockAddress: -1))
            addressary.append(BlockInfo(address: addBlock(), recordsCount: 0, depth: 1, nextBlockAddress: -1))
        } else {
            self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
            self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
            self.overflowDataFile = FileHandle(forUpdatingAtPath: overflowFilePath)!
            load()
        }
    }
    
    // Loader Constructor
    internal init(fileName: String,
                  depth: Int,
                  blockFactor: Int,
                  blockFactorOverflowing: Int,
                  blockCount: Int,
                  maxSize: Int,
                  addressary: [BlockInfo],
                  freeAddresses: [Int],
                  overflowingAddressary: [BlockInfo],
                  freeAddressesOverflowing: [Int]) {
        self.fileName = fileName
        self.depth = depth
        self.blockFactor = blockFactor
        self.blockFactorOverflowing = blockFactorOverflowing

        self.blockCount = blockCount
        self.maxSize = maxSize
        self.addressary = addressary
        self.freeAddresses = freeAddresses
        self.overflowingAddressary = overflowingAddressary
        self.freeAddressesOverflowing = freeAddressesOverflowing
        self.logger = false
        
        let filePath = FileManager.path(to: "\(fileName).hsh")
        let configFilePath = FileManager.path(to: "\(fileName)-config.hsh")
        let overflowFilePath = FileManager.path(to: "\(fileName)-overflow.hsh")
        self.dataFile = FileHandle(forUpdatingAtPath: filePath)!
        self.configFile = FileHandle(forUpdatingAtPath: configFilePath)!
        self.overflowDataFile = FileHandle(forUpdatingAtPath: overflowFilePath)!

    }
    
    //MARK: INSERT
    public func add(_ element: T) {
        var inProgress = true
        debug(logger, "💉💉💉Inserting: \(element.name) - \(element.hash.toRealDecimal()) hash: \(element.hash.desc) key: \(element.hash.toDecimal(depth: depth)) 💉💉💉")
        
        while inProgress {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            let block = loadBlock(by: blockInfo.address, from: dataFile, blockFactor: blockFactor)
            if block.isFull {
                if chainContains(startingBlock: block, startingInfo: blockInfo, element: element){
                    fatalError("Same elements are prohibited in this structure")
                }
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
                debug(logger, "💉✅💉 inserted: \(element.name) - \(element.hash.toRealDecimal())  hash:  \(element.hash.desc)   partialHash:  \(element.hash.toDecimal(depth: depth)) at  \(blockInfo.address) 💉✅💉")
                inProgress = false
            }
        }
    }
    
    private func chainContains(startingBlock: Block<T>, startingInfo: BlockInfo, element: T) -> Bool {
        if startingBlock.records.contains(where: {$0.equals(to: element)}) {
            return true
        } else {
            if startingInfo.nextBlockAddress == -1 {
                return false
            }
            var blockInfo = startingInfo
            while blockInfo.nextBlockAddress != -1 {
                blockInfo = overflowingAddressary.first(where: {$0.address == blockInfo.nextBlockAddress})!
                let block = loadBlock(by: blockInfo.address, from: overflowDataFile, blockFactor: blockFactorOverflowing)
                if block.records.contains(where: {$0.equals(to: element)}) {
                    return true
                }
            }
        }
        return false
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
                if actualBlockInfo.recordsCount < blockFactorOverflowing {
                    inserted = true
                    let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile, blockFactor: blockFactorOverflowing)
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
        if addressary[element.hash.toDecimal(depth: depth)].recordsCount == 0 {
            return nil
        }
        let block = loadBlock(by: element, from: dataFile, blockFactor: blockFactor)
        let result = block.records.first{ $0.equals(to: element)}
        if result == nil {
            let hash = element.hash.toDecimal(depth: depth)
            let blockInfo = addressary[hash]
            if blockInfo.nextBlockAddress == -1 {
                return nil
            }
            var actualBlockInfo = overflowingAddressary.first(where: { $0.address == blockInfo.nextBlockAddress})!
            while true {
                let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile, blockFactor: blockFactorOverflowing)
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
    
    func update(from: T, to: T) {
        var blockInfo = addressary[from.hash.toDecimal(depth: depth)]
        while true {
            let block = loadBlock(by: blockInfo.address, from: dataFile, blockFactor: blockFactor)
            if block.records.contains(where:{ $0.equals(to: from) }) {
                block.delete(from)
                block.add(to)
                break
            }
            if blockInfo.nextBlockAddress != -1 {
                blockInfo = overflowingAddressary.first(where: {$0.address == blockInfo.nextBlockAddress})!
            } else {
                break
            }
        }
    }
    //MARK: DELETE
    public func delete(_ element: T) {
        //TODO: shrinking file ❗️
        let hash = element.hash.toDecimal(depth: depth)
        var blockInfo = addressary[hash]
        var block = loadBlock(by: blockInfo.address, from: dataFile, blockFactor: blockFactor)  //🗄🗄🗄🗄🗄🗄
        debug(logger, "🗑🗑🗑 deleting \(element.desc) from block: \(blockInfo.address) \n🗑🗑🗑")
        
        //If no data found, seek for element in overflowing
        if block.records.contains(where: { $0.equals(to: element) }) {
            if blockInfo.nextBlockAddress != -1 {
                deleteFromBlock(element, block: block, at: blockInfo.address)
                deleteFromLastOverflowing(block: AddressedBlock(address: blockInfo.address, block: block), startingInfo: blockInfo, file: dataFile)
                trimOverflowingIfPossible()
                return
            }
        } else {
            _ = deleteFromOverflowing(element)
            trimOverflowingIfPossible()
            return
        }
        
        //If there is no neighbour, simply remove record and save
        if getNeighbor(of: blockInfo) == nil {
            deleteFromBlock(element, block: block, at: blockInfo.address)
            block.save(with: dataFile, at: blockInfo.address) //🗄🗄🗄🗄🗄🗄
            trimIfPossible()
            return
        }
        deleteFromBlock(element, block: block, at: blockInfo.address)
        
        //Save block and return if merging is not possible
        if blockInfo.recordsCount + getNeighbor(of: blockInfo)!.recordsCount > blockFactor {
            block.save(with: dataFile, at: blockInfo.address) //🗄🗄🗄🗄🗄🗄 once durring method call
            trimIfPossible()
            return
        }
        //Merging cycle
        while blockInfo.recordsCount + getNeighbor(of: blockInfo)!.recordsCount <= blockFactor {
            let secondBlock = loadBlock(by: getNeighbor(of: blockInfo)!.address, from: dataFile, blockFactor: blockFactor) //🗄🗄🗄🗄🗄🗄

            let addressedBlock = mergeBlocks(first: block,
                        firstAddress: blockInfo.address,
                        second: secondBlock,
                        secondAddress: getNeighbor(of: blockInfo)!.address)//🗄🗄🗄🗄🗄🗄 once durring method call
            block = addressedBlock.block

            block.save(with: dataFile, at: addressedBlock.address) // maybe useless
            blockInfo = addressary.first(where: { $0.address == addressedBlock.address})!
            guard let _ = getNeighbor(of: blockInfo) else  {
                trimIfPossible()
                return
            }
        }

    }
    
    private func getNeighbor(of block: BlockInfo) -> BlockInfo? {
        if block.depth == 1 {
            return nil
        }
        let index = addressary.firstIndex(where: { $0.address == block.address })!
        let neighborIndex = index ^ (1 << (depth - block.depth))
        let neighbor = addressary[neighborIndex]
        return neighbor.depth == block.depth ? neighbor : nil
    }
    
    private func deleteFromOverflowing(_ element: T) -> Bool {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        if blockInfo.nextBlockAddress == -1 {
            return false
        }
        var actualBlockInfo = overflowingAddressary.first(where: { $0.address == blockInfo.nextBlockAddress})!
        while true {
            let block = loadBlock(by: actualBlockInfo.address, from: overflowDataFile, blockFactor: blockFactorOverflowing)
            let element = block.records.first{ $0.equals(to: element)}
            if element == nil {
                if actualBlockInfo.nextBlockAddress == -1 {
                    trimOverflowingIfPossible()
                    return false
                }
                actualBlockInfo = overflowingAddressary.first(where: { $0.address == actualBlockInfo.nextBlockAddress})!
            } else {
                deleteFromOverFlowingBlock(element: element!, block: block, at: actualBlockInfo.address)
                deleteFromLastOverflowing(block: AddressedBlock(address: actualBlockInfo.address, block: block), startingInfo: actualBlockInfo, file: overflowDataFile)
                trimOverflowingIfPossible()
                return true
            }
        }
    }
    
    private func deleteFromLastOverflowing(block: AddressedBlock<T>, startingInfo: BlockInfo, file: FileHandle) {
        var lastBlockInfo = startingInfo
        var startIsLast = true
        while lastBlockInfo.nextBlockAddress != -1 {
            lastBlockInfo = overflowingAddressary.first(where: {$0.address == lastBlockInfo.nextBlockAddress})!
            startIsLast = false
        }
        if startIsLast {
            block.block.save(with: file, at: block.address)
            trimOverflowingIfPossible()
            if lastBlockInfo.recordsCount == 0 {
                removeNextBlock(from: lastBlockInfo)
            }
            return
        }
        let lastBlock = loadBlock(by: lastBlockInfo.address, from: overflowDataFile, blockFactor: blockFactorOverflowing)
        let toBeSwapped = popLastFromBlock(block: AddressedBlock(address: lastBlockInfo.address, block: lastBlock))
        if file === dataFile {
            addToBlock(element: toBeSwapped, block: block.block, at: block.address)
        } else {
            addToOverFlowingBlock(element: toBeSwapped, block: block.block, at: block.address)
        }
        if lastBlockInfo.recordsCount == 0 {
            removeNextBlock(from: lastBlockInfo)
        }
        trimOverflowingIfPossible()
        block.block.save(with: file, at: block.address)
    }

    //MARK: OVERFLOW HELPERS
    private func addToOverFlowingBlock(element: T, block: Block<T>, at address: Int) {
        block.add(element)
        overflowingAddressary.first(where: { $0.address == address })!.recordsCount += 1
    }
    
    private func deleteFromOverFlowingBlock(element: T, block: Block<T>, at address: Int) {
        block.delete(element)
        overflowingAddressary.first(where: { $0.address == address })!.recordsCount -= 1
        trimOverflowingIfPossible()
    }
    
    private func addBlockToOverFlow() -> AddressedBlock<T> {
        let address = freeAddressesOverflowing.popLast() ??  Int(overflowDataFile.seekToEndOfFile()) //WARNING: Be careful about cutting ❗️
        overflowingAddressary.append(BlockInfo(address: address, recordsCount: 0, depth: 0, nextBlockAddress: -1))
        let block = Block<T>(blockFactor: blockFactorOverflowing, depth: 0)
        return AddressedBlock(address: address, block: block)
    }
    
    
    //MARK: HELPERS
    private func removeNextBlock(from actualBlock: BlockInfo) {
        let previous = overflowingAddressary.first(where: {$0.nextBlockAddress == actualBlock.address}) ??
            addressary.first(where: {$0.nextBlockAddress == actualBlock.address})!
        previous.nextBlockAddress = -1
        let popped = overflowingAddressary.pop(at: overflowingAddressary.firstIndex(where: {$0.address == actualBlock.address})!)
        let index = freeAddressesOverflowing.insertionIndex(of: popped.address)
        freeAddressesOverflowing.insert(popped.address, at: index)
    }
    
    
    private func addToBlock(element: T, block: Block<T>, at address: Int) {
        block.add(element)
        addressary[addressary.firstIndex(where: { $0.address == address })!].recordsCount += 1
    }
    
    private func deleteFromBlock(_ element: T, block: Block<T>, at address: Int) {
        block.delete(element)
        let blockInAddressary = addressary.first(where: { $0.address == address })!
        blockInAddressary.recordsCount -= 1
        trimIfPossible()
    }
    
    private func popLastFromBlock(block: AddressedBlock<T>) -> T {
        let blockInfo = overflowingAddressary.first(where: { $0.address == block.address})
        blockInfo?.recordsCount -= 1
        let result =  block.block.popLastRecord()
        block.block.save(with: overflowDataFile, at: block.address)
        return result
    }
    
    private func addBlock(_ depth: Int = 1) -> Int {
        let address = freeAddresses.popLast() ?? Int(try! dataFile.seekToEnd()) //WARNING: Be careful about cutting ❗️
        let block = Block<T>(blockFactor: blockFactor, depth: depth)
        dataFile.seek(toFileOffset: UInt64(address))
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

        let newBlock = loadBlock(by: newAddress, from: dataFile, blockFactor: blockFactor)
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
        addressary[addressaryIndex].depth -= 1
        baseBlock.depth -= 1
        let baseNeighbor = addressary.first(where: {$0.address == baseAddress})!.nextBlockAddress
        let secondaryNeighbor = addressary.first(where: {$0.address == secondaryAddress})!.nextBlockAddress
        
        addressary.replaceReferences(toBeReplaced: addressary.firstIndex(where: { $0.address == secondaryAddress})!,
                                     with: addressary.firstIndex(where: { $0.address == baseAddress})!)
        addressary.first(where: {$0.address == baseAddress})?.nextBlockAddress = max(baseNeighbor, secondaryNeighbor)
        baseBlock.save(with: dataFile, at: baseAddress)//🗄🗄🗄🗄🗄🗄
        secondaryBlock.save(with: dataFile, at: secondaryAddress)//🗄🗄🗄🗄🗄🗄
        if !addressary.uniqueReferences.contains(where: { $0.depth == (baseBlock.depth + 1) }) {
            shrinkAddressary()
        }
        return AddressedBlock(address: baseAddress, block: baseBlock)
    }
    
    
    private func loadBlock(by element: T,  from dataFile: FileHandle, blockFactor: Int) -> Block<T> {
        let hash = element.hash.toDecimal(depth: depth)
        let blockInfo = addressary[hash]
        return loadBlock(by: blockInfo.address, from: dataFile, blockFactor: blockFactor)
    }
    
    private func loadBlock(by address: Int, from dataFile: FileHandle, blockFactor: Int) -> Block<T> {
        try! dataFile.seek(toOffset: UInt64(address))
        let bytes = [UInt8](dataFile.readData(ofLength: Block<T>.instantiate(blockFactor).byteSize))
        let block = Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
        return block
    }
    
    private func reAdress(from old: Int, to new: Int, depth: Int) {
        let from = addressary.firstIndex { $0.address == old }!
        let count = addressary.filter{ $0.address == old }.count
        let range = (from + count/2)..<(from + count)
        
        let blockInfo = BlockInfo(address: new, recordsCount: 0, depth: depth, nextBlockAddress: -1) // To keep reference dependency in addressary
        for i in range {
            addressary[i] = blockInfo
        }
        var print = ""
        for adress in addressary {
            print.append(adress.desc)
        }
        debug(logger, "📭📭📭 Changed addresses: \(print) \n📭📭📭")
    }
    
    func save() {
        configFile.seek(toFileOffset: 0)
//        configFile.write(Data(toByteArray()))
        let data = Data(toByteArray())
        try! configFile.write(contentsOf: data)
    }
    
    func load() {
        configFile.seek(toFileOffset: 0)
        let data = configFile.readDataToEndOfFile()
        let bytes = [UInt8](data)
        let loaded = fromByteArray(array: bytes)
        copy(other: loaded)
    }
    
    private func copy(other: ExtensibleHashing) {
        self.depth = other.depth
        self.blockFactor = other.blockFactor
        self.blockFactorOverflowing = other.blockFactorOverflowing
        self.blockCount = other.blockCount
        self.maxSize = other.maxSize
        self.addressary = other.addressary
        self.freeAddresses = other.freeAddresses
        self.overflowingAddressary = other.overflowingAddressary
        self.freeAddressesOverflowing = other.freeAddressesOverflowing
        self.depth = other.depth
    }
    
    private func trimOverflowingIfPossible() {
        while true {
            guard let max = overflowingAddressary.max(by: {$0.address < $1.address})  else {
                return
            }
            if max.recordsCount == 0 {
                overflowDataFile.truncateFile(atOffset: UInt64(max.address))
                return
            } else {
                return
            }
        }
    }
    
    private func trimIfPossible() {
        var lastBlockAddress = Int(dataFile.seekToEndOfFile()) - Block<T>.instantiate(blockFactor).byteSize
        while true {
            if freeAddresses.isEmpty {
                return
            }
            if freeAddresses[0] != lastBlockAddress {
                return
            }
            dataFile.truncateFile(atOffset: UInt64(freeAddresses[0]))
            freeAddresses.remove(at: 0)
            lastBlockAddress = Int(dataFile.seekToEndOfFile()) - Block<T>.instantiate(blockFactor).byteSize
        }
    }
    
    //MARK: DEBUGGING  🐞
    
    var allData: AllData<T> {
        get {
            var overflowBlocks: [AddressedBlock<T>] = []
            var mainBlocks: [AddressedBlock<T>] = []
            var address = 0
            var blockSize = Block<T>.instantiate(blockFactorOverflowing).byteSize
            while overflowDataFile.seekToEndOfFile() > address {
                overflowDataFile.seek(toFileOffset: UInt64(address))
                let bytes = [UInt8](overflowDataFile.readData(ofLength: blockSize))
                if overflowingAddressary.map({$0.address}).contains(address) {
                    let block =  Block<T>.instantiate(blockFactorOverflowing).fromByteArray(array: bytes)
                    overflowBlocks.append(AddressedBlock(address: address, block: block))
                }
                address += blockSize
            }
            
            blockSize = Block<T>.instantiate(blockFactor).byteSize
            address = 0
            while dataFile.seekToEndOfFile() > address {
                dataFile.seek(toFileOffset: UInt64(address))
                let bytes = [UInt8](dataFile.readData(ofLength: blockSize))
                if addressary.map({$0.address}).contains(address) {
                    let block =  Block<T>.instantiate(blockFactor).fromByteArray(array: bytes)
                    mainBlocks.append(AddressedBlock(address: address, block: block))
                }
                address += blockSize
            }
            
            let result = AllData<T>(mainAddressary: addressary.map({UIBlockInfo(blockInfo: $0, neighbor: getNeighbor(of: $0)?.address)}),
                                    overflowAddressary: overflowingAddressary,
                                    mainFreeAddresses: freeAddresses,
                                    overflowAddresses: freeAddresses,
                                    mainBlocks: mainBlocks,
                                    overflowBlocks: overflowBlocks)
            return result
        }
    }
    func printState(headerOnly: Bool = false) {
    }
    
}
//MARK: STORING
extension ExtensibleHashing: Storable {
    var desc: String {
        "asd"
    }
    
    var byteSize: Int {
        let basics = 4 * 8
        let addressary = 8 + BlockInfo.instantiate().byteSize * self.addressary.count
        let freeAddresses = 8 + 8 * self.freeAddresses.count
        let addressaryOverflowing = 8 + BlockInfo.instantiate().byteSize * self.overflowingAddressary.count
        let freeAddressesOverflowing = 8 + 8 * self.freeAddressesOverflowing.count
        
        return basics + addressary + freeAddresses + addressaryOverflowing + freeAddressesOverflowing
//        return 20*2 + 3*8 + 8*addressary.count
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        result.append(contentsOf: depth.toByteArray())                              // 1
        result.append(contentsOf: blockFactor.toByteArray())                        // 2
        result.append(contentsOf: blockFactorOverflowing.toByteArray())                        // 2
        result.append(contentsOf: blockCount.toByteArray())                         // 3
        result.append(contentsOf: maxSize.toByteArray())                            // 4
        
        result.append(contentsOf: addressary.count.toByteArray())                   // 5.1 --40b
        for adress in addressary {                                                  // 5.2
            result.append(contentsOf: adress.toByteArray())
        }
        
        result.append(contentsOf: freeAddresses.count.toByteArray())                // 6.1
        for adress in freeAddresses {                                               // 6.2
            result.append(contentsOf: adress.toByteArray())
        }
        
        result.append(contentsOf: overflowingAddressary.count.toByteArray())        // 7.1
        for blockInfo in overflowingAddressary {                                    // 7.2
            let bytes = blockInfo.toByteArray()
            result.append(contentsOf: bytes)
        }
        
        result.append(contentsOf: freeAddressesOverflowing.count.toByteArray())     // 8.1
        for adress in freeAddressesOverflowing {                                    // 8.2
            result.append(contentsOf: adress.toByteArray())
        }
        return result
    }
    
    func fromByteArray(array: [UInt8]) -> ExtensibleHashing {
        let depth = Int.fromByteArray(Array(array[0..<8]))              // 1
        let blockFactor = Int.fromByteArray(Array(array[8..<16]))       // 2
        let blockFactorOverflowing = Int.fromByteArray(Array(array[16..<24]))
        let blockCount = Int.fromByteArray(Array(array[24..<32]))       // 3
        let maxSize = Int.fromByteArray(Array(array[32..<40]))          // 4
        
        let addressarySize = Int.fromByteArray(Array(array[40..<48]))   // 5.1
                                                                        // 5.2
        var addressary: [BlockInfo] = []
        var actualStart = 48
        var actualEnd = 0
        var previousBlockInfo = BlockInfo(address: -11, recordsCount: -11, depth: -11, nextBlockAddress: -11)
        for _ in 0..<addressarySize {
            actualEnd = actualStart + BlockInfo.instantiate().byteSize
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
        
        var freeAddresses: [Int] = []
        actualEnd = actualStart + 8
        let freeAddressesCount = Int.fromByteArray(Array(array[actualStart..<actualEnd]))   // 6.1
        actualStart = actualEnd
        for _ in 0..<freeAddressesCount {                                                           // 6.2
            actualEnd = actualStart + 8
            let actualBytes = Array(array[actualStart..<actualEnd])
            let address = Int.fromByteArray(actualBytes)
            freeAddresses.append(address)
        }
        
        
        var overflowingAddressary: [BlockInfo] = []
        actualEnd = actualStart + 8
        let overflowingAddressaryCount = Int.fromByteArray(Array(array[actualStart..<actualEnd]))   // 7.1
        actualStart = actualEnd
        for _ in 0..<overflowingAddressaryCount {                                                           // 7.2
            actualEnd = actualStart + BlockInfo.instantiate().byteSize
            let actualBytes = Array(array[actualStart..<actualEnd])
            let actualBlockInfo = BlockInfo().fromByteArray(array: actualBytes)
            overflowingAddressary.append(actualBlockInfo)
            actualStart = actualEnd
        }
        
        var freeAddressesOverflowing: [Int] = []
        actualEnd = actualStart + 8
        let freeAddressesOverflowingCount = Int.fromByteArray(Array(array[actualStart..<actualEnd]))   // 8.1
        actualStart = actualEnd
        for _ in 0..<freeAddressesOverflowingCount {                                                           // 8.2
            actualEnd = actualStart + 8
            let actualBytes = Array(array[actualStart..<actualEnd])
            let address = Int.fromByteArray(actualBytes)
            freeAddressesOverflowing.append(address)
        }
        

        let extensibleHashing = ExtensibleHashing(fileName: fileName,
                                                  depth: depth,
                                                  blockFactor: blockFactor,
                                                  blockFactorOverflowing: blockFactorOverflowing,
                                                  blockCount: blockCount,
                                                  maxSize: maxSize,
                                                  addressary: addressary,
                                                  freeAddresses: freeAddresses,
                                                  overflowingAddressary: overflowingAddressary,
                                                  freeAddressesOverflowing: freeAddressesOverflowing)
        
        return extensibleHashing
    }
    
    static func instantiate() -> ExtensibleHashing {
        return ExtensibleHashing(fileName: "", blockFactor: 0, blockFactorOverflowing: 0) // Dummy method
    }
}
