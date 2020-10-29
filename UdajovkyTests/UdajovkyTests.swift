//
//  UdajovkyTests.swift
//  UdajovkyTests
//
//  Created by hladek on 26/10/2020.
//

import XCTest

class UdajovkyTests: XCTestCase {
    func testReferencesInStaticStructure() throws {
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        let list = [
            KDTreePointImplementation(number: 550, name: 112, speed: 212), // 0
            KDTreePointImplementation(number: 340, name: 832, speed: 123), // 1
            KDTreePointImplementation(number: 190, name: 122, speed: 612), // 2
            KDTreePointImplementation(number: 244, name: 533, speed: 733), // 3
            KDTreePointImplementation(number: 876, name: 423, speed: 934), // 4
            KDTreePointImplementation(number: 930, name: 554, speed: 175), // 5
            KDTreePointImplementation(number: 650, name: 984, speed: 124), // 6
            KDTreePointImplementation(number: 320, name: 145, speed: 256), // 7
            KDTreePointImplementation(number: 432, name: 854, speed: 129), // 8
            KDTreePointImplementation(number: 520, name: 125, speed: 740), // 9
            KDTreePointImplementation(number: 211, name: 534, speed: 560), // 10
            KDTreePointImplementation(number: 921, name: 445, speed: 976), // 11
            KDTreePointImplementation(number: 879, name: 412, speed: 167), // 12
            KDTreePointImplementation(number: 523, name: 916, speed: 185), // 13
            KDTreePointImplementation(number: 540, name: 880, speed: 490), // 14
            KDTreePointImplementation(number: 821, name: 310, speed: 110), // 15
        ]
        for element in list {
            tree.add(element)
        }

//        let ahoj = (tree.rightMinimum(for: tree.root!.leftSon!.leftSon!, by: 3).point.value.desc)
//        print(ahoj)
//        print(tree.rightMinimum(for: tree.root!, by: 3).point.value.desc)

        tree.delete(list[2])

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
        XCTAssert(tree.root?.rightSon?.leftSon?.leftSon?.value === list.last)
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
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        var generator = SeededGenerator(seed: 500)
//        measure {
        for i in 1 ... 100_000 {
            if i % 100_000 == 0 { print("strike----------", i) }
            tree.add(
                KDTreePointImplementation(number: Int.random(in: 1 ... 1000, using: &generator),
                                          name: Int.random(in: 1 ... 1000, using: &generator),
                                          speed: Int.random(in: 1 ... 1000, using: &generator))
            )
        }
//        }
    }
    
    func testTreeDeletion() throws {
        let tree = KDTree<KDTreePointImplementation>(dimensions: 3)
        let list = [
            KDTreePointImplementation(number: 550, name: 112, speed: 212), // 0
        ]
        tree.add(list.first!)
        tree.delete(list.first!)
    }
}
