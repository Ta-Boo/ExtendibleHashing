//
//  AppDelegate.swift
//  Udajovky
//
//  Created by hladek on 02/10/2020.
//

import Cocoa
import SwiftUI



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = MainView()

        if playGround() {
            exit(-1)
        }

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )

        
        
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        

    }
    var properties = [
        Property(registerNumber: 1, id: 255, description: "1: ahoj, ja som property", position: GPS(lat: 43.123, long: 164.3291)),
        Property(registerNumber: 2, id: 254, description: "2: ahoj, ja som property", position: GPS(lat: 43.123, long: 364.3291)),
        Property(registerNumber: 3, id: 253, description: "3: ahoj, ja som property", position: GPS(lat: 13.123, long: 634.3291)),
        Property(registerNumber: 4, id: 220, description: "4: ahoj, ja som property", position: GPS(lat: 43.123, long: 624.3291)),
        Property(registerNumber: 5, id: 221, description: "5: ahoj, ja som property", position: GPS(lat: 53.123, long: 614.3291)),
        Property(registerNumber: 6, id: 120, description: "6: ahoj, ja som property", position: GPS(lat: 23.123, long: 641.3291)),
        Property(registerNumber: 7, id: 190, description: "7: ahoj, ja som property", position: GPS(lat: 14.123, long: 164.3291)),
        Property(registerNumber: 8, id: 189, description: "8: ahoj, ja som property", position: GPS(lat: 15.123, long: 564.3291)),
        Property(registerNumber: 9, id: 231, description: "9: ahoj, ja som property", position: GPS(lat: 11.123, long: 664.3291)),
//        Property(registerNumber: 0, id: 6353, description: "0: ahoj, ja som property", position: GPS(lat: 93.123, long: 864.3291))
    ]
    
    func playGround() -> Bool{
//        print(186.bitSet.desc)
//        print(186.bitSet.toDecimal(depth: 2))
//        return true
        testInsert()
        return true
        
//        65535
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
        for property in properties {
            extensibleHashing.add(property)
        }
        
        for i in 0..<properties.count {
            print(extensibleHashing.find(properties[i])?.desc)
        }
        
        
        return true
    }
    
    func testInsert() {
        for seed in 42 ... 3000 {
            var generator = SeededGenerator(seed: UInt64(seed))
            print("seed:",seed)
            let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
            
            var uniques : [Int] = []
            for i in 0..<6 {
                let random = Int.random(in: 110...255, using: &generator)
                if !uniques.contains(random) {
                    uniques.append(random)
                }
            }
            
            var randomProperties: [Property] = []
            for _ in 1...uniques.count {
                let registerNumber = uniques.popLast()!
                let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
                randomProperties.append(property)
                extensibleHashing.add(property)
            }
            
            for property in randomProperties {
                print(property.desc)
                print(extensibleHashing.find(property)!)
            }
        }
    }
    
    func testInsertAndFind() {
        for seed in 3000 ... 3000 {
            var generator = SeededGenerator(seed: UInt64(seed))
            print("seed:",seed)
            let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
            
            var uniques : [Int] = []
            for i in 0...100 {
                if i % 1000 == 0 {print("---")}
                let random = Int.random(in: 1...255, using: &generator)
                if !uniques.contains(random) {
                    uniques.append(random)
                }
            }
            
            var randomProperties: [Property] = []
            for i in 1...50 {
                let registerNumber = uniques.popLast()!
                let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
                if i % 600 == 0 {
                    randomProperties.append(property)
                }
                extensibleHashing.add(property)
            }
            
            for property in randomProperties {
                print(extensibleHashing.find(property))
            }
        }
    }
}


