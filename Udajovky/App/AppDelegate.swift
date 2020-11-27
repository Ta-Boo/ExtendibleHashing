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
        Property(registerNumber: 1, id: 65535, description: "1: ahoj, ja som property", position: GPS(lat: 43.123, long: 164.3291)),
        Property(registerNumber: 2, id: 32767, description: "2: ahoj, ja som property", position: GPS(lat: 43.123, long: 364.3291)),
        Property(registerNumber: 3, id: 16383, description: "3: ahoj, ja som property", position: GPS(lat: 13.123, long: 634.3291)),
        Property(registerNumber: 4, id: 8191, description: "4: ahoj, ja som property", position: GPS(lat: 43.123, long: 624.3291)),
        Property(registerNumber: 5, id: 4095, description: "5: ahoj, ja som property", position: GPS(lat: 53.123, long: 614.3291)),
        Property(registerNumber: 6, id: 20479, description: "6: ahoj, ja som property", position: GPS(lat: 23.123, long: 641.3291)),
        Property(registerNumber: 7, id: 28671, description: "7: ahoj, ja som property", position: GPS(lat: 14.123, long: 164.3291)),
        Property(registerNumber: 8, id: 1893, description: "8: ahoj, ja som property", position: GPS(lat: 15.123, long: 564.3291)),
        Property(registerNumber: 9, id: 6153, description: "9: ahoj, ja som property", position: GPS(lat: 11.123, long: 664.3291)),
//        Property(registerNumber: 0, id: 6353, description: "0: ahoj, ja som property", position: GPS(lat: 93.123, long: 864.3291))
    ]
    
    func playGround() -> Bool{
        
        
        
//        65535
        let bitset = 5.bitSet
        print(bitset.desc)
        print(bitset.toDecimal(depth: 15))
        print(sizeof(Int.self))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 2)
        for property in properties {
            extensibleHashing.add(property)
        }
        
        for i in 0..<properties.count {
            print(extensibleHashing.find(properties[i])?.desc)
        }
        
        
        return true
    }
    
    func testSave() {
    }
}


