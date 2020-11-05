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

    var isFilled: Bool {
        return !numberHolder.isEmpty &&
                !descriptionHolder.isEmpty &&
                !latitudeHolder.isEmpty &&
                !longitudeHolder.isEmpty
    }
    
    func addPDAObject() {
        if isParcel {
            PDAState.shared.addRealty(Realty(registerNumber: Int(numberHolder)!,
                                           description: descriptionHolder,
                                           plots: [],
                                           gpsPossition: GpsPossition(lattitude: Int(latitudeHolder)!, longitude: Int(longitudeHolder)!),
                                           id: 0))
        } else {
            PDAState.shared.addPlot(Plot(registerNumber: Int(numberHolder)!,
                                         description: descriptionHolder,
                                         realties: [],
                                         gpsPossition: GpsPossition(lattitude: Int(latitudeHolder)!, longitude: Int(longitudeHolder)!),
                                         id: 0))
        }
    }
    
}
