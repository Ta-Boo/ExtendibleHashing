////
////  UdajovkyTests.swift
////  UdajovkyTests
////
////  Created by hladek on 26/10/2020.
////
//
//import XCTest
//
//class UdajovkyTests: XCTestCase {
//    let list = [
//        KDTreePointImplementation(number: 550, name: 112, speed: 212, id: 0), // 0
//        KDTreePointImplementation(number: 340, name: 832, speed: 123, id: 1), // 1
//        KDTreePointImplementation(number: 190, name: 122, speed: 612, id: 2), // 2
//        KDTreePointImplementation(number: 244, name: 533, speed: 733, id: 3), // 3
//        KDTreePointImplementation(number: 876, name: 423, speed: 934, id: 4), // 4
//        KDTreePointImplementation(number: 930, name: 554, speed: 175, id: 5), // 5
//        KDTreePointImplementation(number: 650, name: 984, speed: 124, id: 6), // 6
//        KDTreePointImplementation(number: 320, name: 145, speed: 256, id: 7), // 7
//        KDTreePointImplementation(number: 432, name: 854, speed: 129, id: 8), // 8
//        KDTreePointImplementation(number: 520, name: 125, speed: 740, id: 9), // 9
//        KDTreePointImplementation(number: 211, name: 532, speed: 560, id: 10), // 10
//        KDTreePointImplementation(number: 921, name: 445, speed: 976, id: 11), // 11
//        KDTreePointImplementation(number: 879, name: 412, speed: 167, id: 12), // 12
//        KDTreePointImplementation(number: 523, name: 916, speed: 185, id: 13), // 13
//        KDTreePointImplementation(number: 540, name: 880, speed: 490, id: 14), // 14
//        KDTreePointImplementation(number: 821, name: 310, speed: 110, id: 15), // 15
//        KDTreePointImplementation(number: 216, name: 511, speed: 532, id: 16), // 16
//
//    ]
//
//    let plotList = [
//        Plot(registerNumber: 0, description: "Description of: 0", realties: [], gpsPossition: GpsPossition(lattitude: 6, longitude: 4), id: 1),
//        Plot(registerNumber: 1, description: "Description of: 1", realties: [], gpsPossition: GpsPossition(lattitude: 5, longitude: 3), id: 1),
//        Plot(registerNumber: 2, description: "Description of: 2", realties: [], gpsPossition: GpsPossition(lattitude: 7, longitude: 3), id: 2),
//        Plot(registerNumber: 3, description: "Description of: 3", realties: [], gpsPossition: GpsPossition(lattitude: 5, longitude: 2), id: 3),
//        Plot(registerNumber: 4, description: "Description of: 4", realties: [], gpsPossition: GpsPossition(lattitude: 4, longitude: 4), id: 4),
//        Plot(registerNumber: 5, description: "Description of: 5", realties: [], gpsPossition: GpsPossition(lattitude: 7, longitude: 4), id: 5),
//        Plot(registerNumber: 6, description: "Description of: 6", realties: [], gpsPossition: GpsPossition(lattitude: 6, longitude: 4), id: 6),
//        Plot(registerNumber: 7, description: "Description of: 7", realties: [], gpsPossition: GpsPossition(lattitude: 8, longitude: 5), id: 7),
//        Plot(registerNumber: 8, description: "Description of: 8", realties: [], gpsPossition: GpsPossition(lattitude: 3, longitude: 4), id: 8),
//        Plot(registerNumber: 9, description: "Description of: 9", realties: [], gpsPossition: GpsPossition(lattitude: 4, longitude: 2), id: 9),
//    ]
//
//    func testReferencesInStaticStructure() throws {
//        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
//        for element in list {
//            tree.add(element)
//        }
//
//        XCTAssert(tree.root?.dimension == 1)
//        XCTAssert(tree.root?.leftSon?.dimension == 2)
//        XCTAssert(tree.root?.leftSon?.leftSon?.dimension == 3)
//        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.dimension == 1)
//        XCTAssert(tree.root?.value === list.first)
//        XCTAssert(tree.root?.leftSon?.value === list[1])
//        XCTAssert(tree.root?.rightSon?.value === list[4])
//        XCTAssert(tree.root?.leftSon?.leftSon?.value === list[2])
//        XCTAssert(tree.root?.leftSon?.rightSon?.value === list[8])
//        XCTAssert(tree.root?.leftSon?.leftSon?.rightSon?.rightSon?.value === list[9])
//        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.leftSon?.value === list[10])
//        XCTAssert(tree.root?.leftSon?.rightSon?.rightSon?.rightSon?.value === list[14])
//        XCTAssert(tree.root?.rightSon?.leftSon?.leftSon?.value === list[15])
//    }
//
//    func testDeletionOnStaticTree() throws {
//        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
//        for element in list {
//            tree.add(element)
//        }
//        tree.delete(list[2])
//        XCTAssert(tree.root?.leftSon?.leftSon?.value === list[10])
//        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.value === list[7])
//        XCTAssert(tree.root?.leftSon?.leftSon?.leftSon?.leftSon?.value === list[16])
//    }
//
//    func testSeededGenerator() throws {
//        var array: [Int] = []
//        var generator = SeededGenerator(seed: 50)
//
//        for _ in 1 ... 10000 {
//            array.append(Int.random(in: 1 ... 10000, using: &generator))
//        }
//
//        let std = Int(Double(array.count) * 0.025)
//        XCTAssert(((array.count / 2 - std) ... (array.count / 2 + std)).contains(array.reduce(0, +) / array.count))
//    }
//
//    func testFind() throws {
//        let lowerBound = KDTreePointImplementation(number: 550, name: 112, speed: 212, id: 0)
//        let upperBound = KDTreePointImplementation(number: 1000, name: 1000, speed: 1000, id: 1000)
//        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
//        for element in list {
//            tree.add(element)
//        }
//        XCTAssert(tree.findElements(lowerBound: lowerBound, upperBound: upperBound).count == 3)
//    }
//
//
//    func testStaticOperations() {
//        var generator = SeededGenerator(seed: UInt64(1234567))
//        let tree = KDTree<Plot>(dimensions: 2)
//        var helperList: [Plot] = []
//
//        for id in  1 ... 10000  {
//            if id % 2500 == 0 { print(Double(id) / 100.0, "%") }
//
//            let plot = Plot(registerNumber: 1,
//                            description: "something",
//                            realties: [],
//                            gpsPossition: GpsPossition(lattitude: Int.random(in: 0 ... 10, using: &generator),
//                                                       longitude: Int.random(in: 0 ... 10, using: &generator)),
//                            id: id)
//            helperList.append(plot)
//            tree.add(plot)
//        }
//        print(tree.count)
//
//        for y in 1 ... 1000 {
//            print(y)
//            if y % 250 == 0 { print(Double(y) / 10.0, "%") }
//            let element = helperList.randomElement()!
//            tree.delete(element)
//        }
//        print(tree.count)
//
//    }
//
//    func testRandomOperations() throws {
//        //9570
//        let operations = 100_000
//        // 180 1...6
////        for operations in 10000...10000 {
//        for seed in 10000 ... 10000 {
//
//            print("Seed: \(seed)")
//            var generator = SeededGenerator(seed: UInt64(seed))
//                print("Number of operations: \(operations)")
//                print("⭕️OPERATIONS CYCLE⭕️")
//                let tree = KDTree<Plot>(dimensions: 2)
//                var helperList: [Plot] = []
//                for y in 1...operations {
//
////                    if y % 2500 == 0 { print(Double(y) / 100.0, "%") }
//
//                    let probability = Double.random(in: 0.0 ... 1.0, using: &generator)
//                    if probability < 0.7 || helperList.isEmpty {
//                        var realties: [Realty] = []
//                        for _ in 1 ... Int.random(in: 1 ... 8, using: &generator) {
//                            realties.append(
//                                Realty(registerNumber: Int.random(in: 1 ... 50, using: &generator),
//                                       description: "something",
//                                       plots: [],
//                                       gpsPossition: GpsPossition(lattitude: Int.random(in: 0 ... 3, using: &generator),
//                                                                  longitude: Int.random(in: 0 ... 3, using: &generator)),
//                                       id: y)
//                            )
//                        }
//
//                        let plot = Plot(registerNumber: Int.random(in: 1 ... 50, using: &generator),
//                                        description: "something",
//                                        realties: [],
//                                        gpsPossition: GpsPossition(lattitude: Int.random(in: 0 ... 10, using: &generator),
//                                                                   longitude: Int.random(in: 0 ... 10, using: &generator)),
//                                        id: y)
//
//                        helperList.append(plot)
////                        print("Adding:   ", plot.desc)
//                        tree.add(plot)
//                    } else {
//                        let number = Int.random(in: 0 ..< helperList.count, using: &generator)
//                        let element = helperList[number]
//                        helperList.remove(at: number)
////                        print("Removing: ", element.desc)
//                        tree.refactorDelete(element)
//                    }
//                }
//            }
////        }
//    }
//
//    func testRefactoredDelete() {
//        let tree = KDTree<Plot>(dimensions: 2)
//        let customList = [
//            Plot(registerNumber: 0, description: "Description of: 0", realties: [], gpsPossition: GpsPossition(lattitude: 8, longitude: 20), id: 1),
//            Plot(registerNumber: 0, description: "Description of: 0", realties: [], gpsPossition: GpsPossition(lattitude: 7, longitude: 18), id: 1),
//            Plot(registerNumber: 0, description: "Description of: 0", realties: [], gpsPossition: GpsPossition(lattitude: 6, longitude: 15), id: 1),
//            Plot(registerNumber: 0, description: "Description of: 0", realties: [], gpsPossition: GpsPossition(lattitude: 5, longitude: 17), id: 1),
//
//        ]
//        for plot in customList {
//            tree.add(plot)
//        }
//        print("Count: \(tree.count)")
//        tree.refactorDelete(customList[1])
//        print("Count: \(tree.count)")
//
//    }
//
//    func testTreeDeletion() throws {
//        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
//        tree.add(list.first!)
//        tree.add(list[1])
//        tree.delete(list[1])
//    }
//
//    func testInsert() throws {
//            // 1M 13,2s
//            let tree = KDTree<Plot>(dimensions: 2)
//
//            for y in 1 ... 1_000_000 {
//                if y % 2500 == 0 { print(Double(y) / 10000.0, "%") }
//                let plot = Plot(registerNumber: 1,
//                                description: "asd",
//                                realties: [],
//                                gpsPossition: GpsPossition(lattitude: Int.random(in: 0 ... 100),
//                                                           longitude: Int.random(in: 0 ... 100)),
//                                id: y)
//
//                tree.add(plot)
//            }
//    }
//}
