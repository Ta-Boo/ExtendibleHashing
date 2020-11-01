//
//  UdajovkyTests.swift
//  UdajovkyTests
//
//  Created by hladek on 26/10/2020.
//

import XCTest

class UdajovkyTests: XCTestCase {
    let list = [
        KDTreePointImplementation(number: 550, name: 112, speed: 212, id: 0), // 0
        KDTreePointImplementation(number: 340, name: 832, speed: 123, id: 1), // 1
        KDTreePointImplementation(number: 190, name: 122, speed: 612, id: 2), // 2
        KDTreePointImplementation(number: 244, name: 533, speed: 733, id: 3), // 3
        KDTreePointImplementation(number: 876, name: 423, speed: 934, id: 4), // 4
        KDTreePointImplementation(number: 930, name: 554, speed: 175, id: 5), // 5
        KDTreePointImplementation(number: 650, name: 984, speed: 124, id: 6), // 6
        KDTreePointImplementation(number: 320, name: 145, speed: 256, id: 7), // 7
        KDTreePointImplementation(number: 432, name: 854, speed: 129, id: 8), // 8
        KDTreePointImplementation(number: 520, name: 125, speed: 740, id: 9), // 9
        KDTreePointImplementation(number: 211, name: 532, speed: 560, id: 10), // 10
        KDTreePointImplementation(number: 921, name: 445, speed: 976, id: 11), // 11
        KDTreePointImplementation(number: 879, name: 412, speed: 167, id: 12), // 12
        KDTreePointImplementation(number: 523, name: 916, speed: 185, id: 13), // 13
        KDTreePointImplementation(number: 540, name: 880, speed: 490, id: 14), // 14
        KDTreePointImplementation(number: 821, name: 310, speed: 110, id: 15), // 15
        KDTreePointImplementation(number: 216, name: 511, speed: 532, id: 16), // 16
    ]
    
    func testReferencesInStaticStructure() throws {
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        for element in list {
            tree.add(element)
        }
        
        XCTAssert(tree.root?.dimension == 1)
        XCTAssert(tree.root?.leftSon?.dimension == 2)
        XCTAssert(tree.root?.leftSon?.leftSon?.dimension == 3)
        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.dimension == 1)
        XCTAssert(tree.root?.value === list.first)
        XCTAssert(tree.root?.leftSon?.value === list[1])
        XCTAssert(tree.root?.rightSon?.value === list[4])
        XCTAssert(tree.root?.leftSon?.leftSon?.value === list[2])
        XCTAssert(tree.root?.leftSon?.rightSon?.value === list[8])
        XCTAssert(tree.root?.leftSon?.leftSon?.rightSon?.rightSon?.value === list[9])
        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.leftSon?.value === list[10])
        XCTAssert(tree.root?.leftSon?.rightSon?.rightSon?.rightSon?.value === list[14])
        XCTAssert(tree.root?.rightSon?.leftSon?.leftSon?.value === list[15])
    }
    func testDeletionOnStaticTree() throws {
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        for element in list {
            tree.add(element)
        }
        tree.delete(list[2])
        XCTAssert(tree.root?.leftSon?.leftSon?.value === list[10])
        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.value === list[7])
        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.leftSon?.value === list[16])
        
        
    }
    
    func testSeededGenerator() throws {
        var array: [Int] = []
        var generator = SeededGenerator(seed: 50)
        
        for _ in 1 ... 10000 {
            array.append(Int.random(in: 1 ... 10000, using: &generator))
        }
        
        let std = Int(Double(array.count) * 0.025)
        XCTAssert(((array.count / 2 - std) ... (array.count / 2 + std)).contains(array.reduce(0, +) / array.count))
    }
    
    func testRandomOperations() throws {
        
        //        measure {
        //        }
        
        for seed in 973...10000 {
            let tree = KDTree<Plot>(dimensions: 3)
            var helperList: [Plot] = []
            print(seed)
            var generator = SeededGenerator(seed: UInt64(seed))
            for y in 1...8 {
                if y % 2_500 == 0 {print(Double(y) / 100.0,"%")}
                
                let probability = Double.random(in: 0.0...1.0, using: &generator)
                if probability < 0.7  || helperList.isEmpty {
                    var realties: [Realty] = []
                    for _ in 1...Int.random(in: 1...8, using: &generator) {
                        realties.append(
                            Realty(registerNumber: Int.random(in: 1 ... 50, using: &generator),
                                   description: String.random(length: 32)
                            )
                        )
                    }
                    
                    let plot = Plot(registerNumber: Int.random(in: 1 ... 50, using: &generator),
                                    description: Int.random(in: 1 ... 50, using: &generator),
                                    realties: realties,
                                    gpsPossition: Double.random(in: 0...90.000000, using: &generator),
                                    id: y)
                    
                    helperList.append(plot)
                    print("Adding: ",plot.desc )
                    tree.add(plot)
                } else {
                    let number = Int.random(in: 0..<helperList.count, using: &generator)
                    let element = helperList[number]
                    helperList.remove(at: number)
                    print("Removing: ",element.desc )
                    
                    tree.delete(element)
                }
            }
            
        }
    }
    
    func testTreeDeletion() throws {
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        tree.add(list.first!)
        tree.add(list[1])
        tree.delete(list[1])
    }
    
    func testInsert() throws {
        measure {
            let tree = KDTree<Plot>(dimensions: 3)
            var generator = SeededGenerator(seed: UInt64(300))

            for y in 1...100_000 {
                if y % 2_500 == 0 {print(Double(y) / 1000.0,"%")}
                
                var realties: [Realty] = []
                //                for _ in 1...Int.random(in: 1...8, using: &generator) {
                realties.append(
                    Realty(registerNumber: Int.random(in: 1 ... 50, using: &generator),
                           description: String.random(length: 32)
                    )
                )
                //                }
                
                let plot = Plot(registerNumber: Int.random(in: 1 ... 50, using: &generator),
                                description: Int.random(in: 1 ... 50, using: &generator),
                                realties: realties,
                                gpsPossition: Double.random(in: 0...90.000000, using: &generator),
                                id: y)
                
                tree.add(plot)
            }
        }
    }
}
