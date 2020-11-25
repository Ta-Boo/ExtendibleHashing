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
//        print("Int = ",MemoryLayout<Int>.size)
//        print("Double = ",MemoryLayout<Double>.size)
        print("Bool = ",MemoryLayout<BitSet>.size)
        
//        var bits = BitSet(size: 8)
//        bits[2] = true
//        bits[4] = true
//        bits[6] = true
        let bits = 3.bitSet
        for bit in 0..<32 {
            print(bit,bits[bit])
        }
        
        let property = Property(registerNumber: 123,
                                id: 3214,
                                description: "ahoj, ja som property",
                                position: GPS(lat: 13.123, long: 64.3291))
        
        let extensibleHashing = ExtensibleHashing(fileName: "first", blockFactor: 4)
        extensibleHashing.testSave(bytes: property.toByteArray())
        let result = extensibleHashing.testLoad()
        print(result.desc)
        return true
    }
}


