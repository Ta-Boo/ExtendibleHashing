//
//  PlaceFormViewModel.swift
//  Udajovky
//
//  Created by hladek on 05/11/2020.
//

import SwiftUI

class PlaceFormViewModel: ObservableObject {
    @Published var numberHolder: String = ""
    @Published var descriptionHolder: String = ""
    @Published var latitudeHolder: String = ""
    @Published var longitudeHolder: String = ""
    @Published var isParcel = true
    @Published var lattIsPositive = true
    @Published var longIsPositive = true
    
    var isFilled: Bool {
        return !numberHolder.isEmpty &&
            !descriptionHolder.isEmpty &&
            !latitudeHolder.isEmpty &&
            !longitudeHolder.isEmpty
    }
    
    func addPDAObject() {
        PDAState.shared.insert(Property(registerNumber: Int(numberHolder)!,
                                        id: Int(numberHolder)!,
                                        description: descriptionHolder,
                                        position: GPS(lat: Double(latitudeHolder)!,
                                                      long: Double(longitudeHolder)!)))
        
    }
    
}
