//
//  URL.swift
//  Udajovky
//
//  Created by hladek on 24/11/2020.
//

import Foundation

extension URL {
    var corrected: String {
        get {
            return self.relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        }
    }
}

extension FileManager {
    static func path(to file: String) -> String{
        return FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask)[0].appendingPathComponent("GPS\\\(file)").corrected
    }
}
