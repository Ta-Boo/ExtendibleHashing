import Foundation
import Cocoa

struct GPSRange {
    let upper: GpsPossition
    let lower: GpsPossition
}

class PDAState {
    static let shared = PDAState()
    private var objectsID = 0
    var plots: KDTree<Plot> = KDTree(dimensions: 2)
    var realties: KDTree<Realty> = KDTree(dimensions: 2)
        
    //MARK: GET
    func getPlots(matching range: GPSRange) -> [Plot] {
        let upperBound = Plot(gpsPossition: range.upper)
        let lowerBound = Plot(gpsPossition: range.lower)
        let result = plots.findElements(lowerBound: lowerBound, upperBound: upperBound)
        return Array(result.prefix(30))
    }
    
    func getRealties(matching range: GPSRange) -> [Realty] {
        let upperBound = Realty(gpsPossition: range.upper)
        let lowerBound = Realty(gpsPossition: range.lower)
        let result = realties.findElements(lowerBound: lowerBound, upperBound: upperBound)
        return Array(result.prefix(30))
    }
    
    //MARK: UPDATE
    func updatePlot(original: Plot, updated: Plot) {
        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty) 
        updated.realties = connectedRealties
        plots.edit(oldValue: original, newValue: updated)
        
        let fakeRealtyOriginal = Realty(gpsPossition: GpsPossition(lattitude: original.gpsPossition.lattitude, longitude: original.gpsPossition.longitude))
        let connectedRealtiesOriginal = realties.findElements(lowerBound: fakeRealtyOriginal, upperBound: fakeRealtyOriginal)
        for realty in connectedRealtiesOriginal {
            realty.plots = plots.findElements(lowerBound: original, upperBound: original)
        }

        let fakeRealtytUpdated = Realty(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedRealtiesUpdated = realties.findElements(lowerBound: fakeRealtytUpdated, upperBound: fakeRealtytUpdated)
        for realty in connectedRealtiesUpdated {
            realty.plots = plots.findElements(lowerBound: updated, upperBound: updated)
        }
    }
    
    func updateRealty(original: Realty, updated: Realty) {
        let fakePlot = Plot(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedPlots = plots.findElements(lowerBound: fakePlot, upperBound: fakePlot)
        updated.plots = connectedPlots
        realties.edit(oldValue: original, newValue: updated)
        
        let fakePlotOriginal = Plot(gpsPossition: GpsPossition(lattitude: original.gpsPossition.lattitude, longitude: original.gpsPossition.longitude))
        let connectedPlotsOriginal = plots.findElements(lowerBound: fakePlotOriginal, upperBound: fakePlotOriginal)
        for plot in connectedPlotsOriginal {
            plot.realties = realties.findElements(lowerBound: original, upperBound: original)
        }
        
        let fakePlotUpdated = Plot(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedPlotsUpdated = plots.findElements(lowerBound: fakePlotUpdated, upperBound: fakePlotUpdated)
        for plot in connectedPlotsUpdated {
            plot.realties = realties.findElements(lowerBound: updated, upperBound: updated)
        }
    }
    
    //MARK: DELETE
    func deletePlot(plot: Plot) {
        plots.delete(plot)
        
        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: plot.gpsPossition.lattitude, longitude: plot.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty)
        for realty in connectedRealties {
            realty.plots = realty.plots.filter{ !$0.equals(to: plot) }
        }
    }
    
    func deleteRealty(realty: Realty) {
        realties.delete(realty)
        
        let fakePlot = Plot(gpsPossition: GpsPossition(lattitude: realty.gpsPossition.lattitude, longitude: realty.gpsPossition.longitude))
        let connectedPlots = plots.findElements(lowerBound: fakePlot, upperBound: fakePlot)
        for plot in connectedPlots {
            plot.realties = plot.realties.filter{ !$0.equals(to: realty) }
        }
    }
    
    //MARK: ADD
    func addPlot(_ plot: Plot) {
        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: plot.gpsPossition.lattitude, longitude: plot.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty)
        
        
        let updatedPlot = Plot(registerNumber: plot.registerNumber,
                               description: plot.description,
                               realties: connectedRealties,
                               gpsPossition: plot.gpsPossition,
                               id: objectsID)
        for realty in connectedRealties {
            realty.plots.append(updatedPlot)
        }
        objectsID += 1
        plots.add(updatedPlot)
    }
    
    func addRealty(_ realty: Realty) {        
        let fakePlot = Plot(gpsPossition: GpsPossition(lattitude: realty.gpsPossition.lattitude, longitude: realty.gpsPossition.longitude))
        let connectedPlots = plots.findElements(lowerBound: fakePlot, upperBound: fakePlot) // here should be rectangle IMO
        let updatedRealty = Realty(registerNumber: realty.registerNumber,
                               description: realty.description,
                               plots: connectedPlots,
                               gpsPossition: realty.gpsPossition,
                               id: objectsID)
        for plot in connectedPlots {
            plot.realties.append(updatedRealty)
        }
        objectsID += 1 //FIXME: ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
        realties.add(updatedRealty)
    }
    
    //MARK: HELPERS
    func generate () {
        let range = 0 ..< 20_000
        let maxRange = range.max()!
        for y in range {
            let plot = Plot(registerNumber: y,
                            description: "String.random(length: 12)",
                            realties: [],
                            gpsPossition: GpsPossition(lattitude: Double.random(in: -90 ... 90),
                                                       longitude: Double.random(in: -90 ... 90)),
                            id: y)
            
            addPlot(plot)
        }
        for y in range {
            let realty = Realty(registerNumber: y + maxRange + 1,
                            description: "String.random(length: 12)",
                            plots: [],
                            gpsPossition: GpsPossition(lattitude: Double.random(in: -90 ... 90),
                                                       longitude: Double.random(in: -90 ... 90)),
                            id: y + maxRange + 1)

            addRealty(realty)
        }
    }
    
    func save() {
        var plotsResult = ""
        var realtiesResult = ""

        for plot in plots.values {
            plotsResult.append("\(plot.serialize())|")
        }
        plotsResult = String(plotsResult.dropLast())
        
        for realty in realties.values {
            realtiesResult.append("\(realty.serialize())|")
        }
        realtiesResult = String(realtiesResult.dropLast())
        
        let plotsFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("PDAStatePlots.txt")
        do {
            try! plotsResult.write(to: plotsFile, atomically: true, encoding: String.Encoding.utf8)
        }
        
        let realtiesFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("PDAStateRealties.txt")
        do {
            try! realtiesResult.write(to: realtiesFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }
    
    func load() {
        let plotsFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("PDAStatePlots.txt")
        let realtiesFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("PDAStateRealties.txt")

        let plots = try! String(contentsOf: plotsFile, encoding: .utf8)
        let realties = try! String(contentsOf: realtiesFile, encoding: .utf8)
        
        let plotStrings = plots.split(separator: "|")
        for plotString in plotStrings {
            addPlot(Plot.deserialize(from: String(plotString)))
        }
        
        let realtyStrings = realties.split(separator: "|")
        for realtyString in realtyStrings {
            addRealty(Realty.deserialize(from: String(realtyString)))
        }
    }
    

}
