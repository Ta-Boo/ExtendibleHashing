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
        Property(registerNumber: 1, id: 1, description: "1: ahoj, ja som property", position: GPS(lat: 43.123, long: 164.3291)),
        Property(registerNumber: 2, id: 2, description: "2: ahoj, ja som property", position: GPS(lat: 43.123, long: 364.3291)),
        Property(registerNumber: 3, id: 3, description: "3: ahoj, ja som property", position: GPS(lat: 13.123, long: 634.3291)),
        Property(registerNumber: 4, id: 4, description: "4: ahoj, ja som property", position: GPS(lat: 43.123, long: 624.3291)),
        Property(registerNumber: 5, id: 5, description: "5: ahoj, ja som property", position: GPS(lat: 53.123, long: 614.3291)),
        Property(registerNumber: 6, id: 6, description: "6: ahoj, ja som property", position: GPS(lat: 23.123, long: 641.3291)),
        Property(registerNumber: 7, id: 7, description: "7: ahoj, ja som property", position: GPS(lat: 14.123, long: 164.3291)),
//        Property(registerNumber: 8, id: 8, description: "8: ahoj, ja som property", position: GPS(lat: 15.123, long: 564.3291)),
//        Property(registerNumber: 9, id: 9, description: "9: ahoj, ja som property", position: GPS(lat: 11.123, long: 664.3291)),
//        Property(registerNumber: 0, id: 0, description: "0: ahoj, ja som property", position: GPS(lat: 93.123, long: 864.3291))
    ]
    
    func playGround() -> Bool{
//        testSave()
//        return true
        print(1.toByteArray())
        print(sizeof(Int.self))
        let extensibleHashing = ExtensibleHashing<Property>(fileName: "first", blockFactor: 4)
        for property in properties {
            extensibleHashing.add(property)
        }
//        extensibleHashing.testSave(bytes: property.toByteArray())
//        let result = extensibleHashing.testLoad()
//        extensibleHashing.testBlockSave()
//        extensibleHashing.testBlockLoad()
        return true
    }
    
    func testSave() {
//        let array : [UInt8] = [4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 55, 58, 32, 97, 104, 111, 106, 44, 32, 106, 97, 32, 115, 111, 109, 32, 112, 114, 111, 112, 101, 114, 116, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 229, 208, 34, 219, 249, 62, 44, 64, 163, 35, 185, 252, 135, 138, 100, 64]
//        let savedBlock = Block<Property>.instantiate(4).fromByteArray(array: array)
//        let varray = 1234.toByteArray()
//        print(Int.fromByteArray([1,0,0,0,0,0,0,0]))
    }
}


