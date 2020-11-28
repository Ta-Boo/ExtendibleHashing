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

    
    func playGround() -> Bool{
        testInsertAndFind()
        return true
    }
    
    func testStaticOperations() {
        let properties = [
            Property(registerNumber: 0, id: 0, description: "Žilina", position: GPS(lat: 43.123, long: 164.3291)),
            Property(registerNumber: 1, id: 100, description: "Košice", position: GPS(lat: 43.123, long: 364.3291)),
            Property(registerNumber: 2, id: 149, description: "Martin", position: GPS(lat: 13.123, long: 634.3291)),
            Property(registerNumber: 3, id: 187, description: "Levice", position: GPS(lat: 43.123, long: 624.3291)),
            Property(registerNumber: 4, id: 165, description: "Trnava", position: GPS(lat: 53.123, long: 614.3291)),
            Property(registerNumber: 5, id: 182, description: "Snina", position: GPS(lat: 23.123, long: 641.3291)),
            Property(registerNumber: 6, id: 160, description: "Senica", position: GPS(lat: 14.123, long: 164.3291)),
            Property(registerNumber: 7, id: 108, description: "Nitra", position: GPS(lat: 15.123, long: 564.3291)),
            Property(registerNumber: 8, id: 0, description: "Poprad", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 100, description: "Lučenec", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 233, description: "Zvolen", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 240, description: "Prešov", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 183, description: "Púchov", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 15, description: "Ilava", position: GPS(lat: 11.123, long: 664.3291)),
            Property(registerNumber: 9, id: 60, description: "Brezno", position: GPS(lat: 11.123, long: 664.3291)),
        ]
        
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 5)
        for property in properties {
            extensibleHashing.add(property)
        }
        
        for i in 0..<properties.count {
            print(extensibleHashing.find(properties[i])!.desc)
        }
    }
    
    func testInsert() {
        for seed in 21 ... 1000 {
            var generator = SeededGenerator(seed: UInt64(seed))
            print("seed:",seed)
            let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 3)
            
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
                _ = extensibleHashing.find(property)!
            }
        }
    }
    
    func testInsertAndFind() {
        var generator = SeededGenerator(seed: UInt64(1))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
        
        var uniques : [Int] = []
        for i in 0...1000 {
            uniques.append(i)
        }
        uniques.shuffle(using: &generator)
        
        var randomProperties: [Property] = []
        for i in 1...1000 {
            if i % 100 == 0 {print("\(i)/1000")}
            let registerNumber = uniques.popLast()!
            let property = Property(registerNumber: registerNumber, id: registerNumber, description: "asdadasdad", position: GPS(lat: 1, long: 1))
//            if i % 60 == 0 {
                randomProperties.append(property)
//            }
            extensibleHashing.add(property)
        }
        
        for property in randomProperties {
            print(extensibleHashing.find(property)!)
        }
    }
}


