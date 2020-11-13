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
        return Array(result.prefix(230))
    }
    
    func getRealties(matching range: GPSRange) -> [Realty] {
        let upperBound = Realty(gpsPossition: range.upper)
        let lowerBound = Realty(gpsPossition: range.lower)
        let result = realties.findElements(lowerBound: lowerBound, upperBound: upperBound)
        return Array(result.prefix(230))
    }
    
    //MARK: UPDATE
    func updatePlot(original: Plot, updated: Plot) {
        if original.gpsPossition == updated.gpsPossition {
            plots.edit(oldValue: original, newValue: updated)
            return
        }

        for realty in original.realties {
            realty.plots = realty.plots.filter{ !$0.equals(to: original) }
        }

        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty)
        updated.realties = connectedRealties
        plots.edit(oldValue: original, newValue: updated)

        for realty in updated.realties {
            realty.plots.append(updated)
        }
    }
    
    func updateRealty(original: Realty, updated: Realty) {
        
        if original.gpsPossition == updated.gpsPossition {
            realties.edit(oldValue: original, newValue: updated)
            return
        }

        for plot in original.plots {
            plot.realties = plot.realties.filter{ !$0.equals(to: original) }
        }

        let fakePlot = Plot(gpsPossition: GpsPossition(lattitude: updated.gpsPossition.lattitude, longitude: updated.gpsPossition.longitude))
        let connectedPlots = plots.findElements(lowerBound: fakePlot, upperBound: fakePlot)
        updated.plots = connectedPlots
        realties.edit(oldValue: original, newValue: updated)

        for plot in updated.plots {
            plot.realties.append(updated)
        }
    }
    
    //MARK: DELETE
    func deletePlot(plot: Plot) {
        plots.delete(plot)
        for realty in plot.realties {
            realty.plots = realty.plots.filter{ !$0.equals(to: plot) }
        }
    }
    
    func deleteRealty(realty: Realty) {
        realties.delete(realty)
        for plot in realty.plots {
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
                            description: "Generovana",
                            realties: [],
                            gpsPossition: GpsPossition(lattitude: Double(Int.random(in: 1 ... 100)),
                                                       longitude: Double(Int.random(in: 1 ... 100))),
                            id: y)
            
            addPlot(plot)
        }
        for y in 1...5_000 {
            let realty = Realty(registerNumber: y + maxRange + 1,
                            description: "Generovana",
                            plots: [],
                            gpsPossition: GpsPossition(lattitude: Double(Int.random(in: 1 ... 100)),
                                                       longitude: Double(Int.random(in: 1 ... 100))),
                            id: y + 5_000 + 1)

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
