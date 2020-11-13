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
        let latMultiplier: Double = lattIsPositive ? 1 : -1
        let longMultiplier: Double = longIsPositive ? 1 : -1
        if isParcel {
            PDAState.shared.addPlot(Plot(registerNumber: Int(numberHolder)!,
                                         description: descriptionHolder,
                                         realties: [],
                                         gpsPossition: GpsPossition(lattitude: Double(latitudeHolder)! * latMultiplier,
                                                                    longitude: Double(longitudeHolder)! * longMultiplier),
                                         id: 0))
            
        } else {
            PDAState.shared.addRealty(Realty(registerNumber: Int(numberHolder)!,
                                           description: descriptionHolder,
                                           plots: [],
                                           gpsPossition: GpsPossition(lattitude: Double(latitudeHolder)! * latMultiplier,
                                                                      longitude: Double(longitudeHolder)! * longMultiplier),
                                           id: 0))
        }
    }
    
}
