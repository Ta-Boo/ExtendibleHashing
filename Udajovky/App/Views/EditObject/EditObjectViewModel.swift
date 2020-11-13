//
//  EditObjectViewModel.swift
//  Udajovky
//
//  Created by hladek on 08/11/2020.
//

import Foundation

class EditObjectViewModel: ObservableObject {
    var originalRealty: Realty?
    var originalPlot: Plot?
    let title: String
    
    @Published var numberHolder: String = ""
    @Published var descriptionHolder: String = ""
    @Published var latitudeHolder: String = ""
    @Published var longitudeHolder: String = ""
    
    @Published var lattIsPositive = true
    @Published var longIsPositive = true
    
    var isFilled: Bool {
        return !numberHolder.isEmpty &&
                !descriptionHolder.isEmpty &&
                !latitudeHolder.isEmpty &&
                !longitudeHolder.isEmpty
    }
    
    init(title: String, realty: Realty? = nil, plot: Plot? = nil) {
        
        if let realty = realty {
            self.originalRealty = realty
            numberHolder = "\(realty.registerNumber)"
            descriptionHolder = "\(realty.description)"
            latitudeHolder = "\(realty.gpsPossition.lattitude)"
            longitudeHolder = "\(realty.gpsPossition.longitude)"
            lattIsPositive = realty.gpsPossition.lattitude > 0
            longIsPositive = realty.gpsPossition.longitude > 0
        }
        if let plot = plot {
            self.originalPlot = plot
            numberHolder = "\(plot.registerNumber)"
            descriptionHolder = "\(plot.description)"
            latitudeHolder = "\(plot.gpsPossition.lattitude)"
            longitudeHolder = "\(plot.gpsPossition.longitude)"
            lattIsPositive = plot.gpsPossition.lattitude > 0
            longIsPositive = plot.gpsPossition.longitude > 0
        }
        self.title = title
    }
    
    func deleteObject() {
        if let originalRealty = originalRealty {
            PDAState.shared.deleteRealty(realty: originalRealty)
        }
        if let originalPlot = originalPlot {
            PDAState.shared.deletePlot(plot: originalPlot)
        }
    }
    
    func confirm() {
        let latMultiplier: Double = lattIsPositive ? 1 : -1
        let longMultiplier: Double = longIsPositive ? 1 : -1
        if let originalRealty = originalRealty {
            let editedRealty = Realty(registerNumber: Int(numberHolder)!,
                                       description: descriptionHolder,
                                       plots: originalRealty.plots,
                                       gpsPossition: GpsPossition(lattitude: Double(latitudeHolder)! * latMultiplier,
                                                                  longitude: Double(longitudeHolder)! * longMultiplier),
                                       id: originalRealty.id)
            PDAState.shared.updateRealty(original: originalRealty, updated: editedRealty)
            
        }
        if let originalPlot = originalPlot {
            let editedPlot = Plot(registerNumber: Int(numberHolder)!,
                                       description: descriptionHolder,
                                       realties: originalPlot.realties,
                                       gpsPossition: GpsPossition(lattitude: Double(latitudeHolder)! * latMultiplier,
                                                                  longitude: Double(longitudeHolder)! * longMultiplier),
                                       id: originalPlot.id)
            PDAState.shared.updatePlot(original: originalPlot, updated: editedPlot)
        }
    }
}
