import Foundation

struct GPSRange {
    let upper: GpsPossition
    let lower: GpsPossition
}

class PDAState {
    static let shared = PDAState()
    var plotID = 0
    var realtyID = 0
    var plots: KDTree<Plot> = KDTree(dimensions: 2)
    var realties: KDTree<Realty> = KDTree(dimensions: 2)
    
    private init () {
//        addPlot(Plot(registerNumber: 2, description: "Parcela 1", realties: [], gpsPossition: GpsPossition(lattitude: 8.0, longitude: 8.0), id: 1))
//        addPlot(Plot(registerNumber: 0, description: "Parcela 2", realties: [], gpsPossition: GpsPossition(lattitude: 10.0, longitude: 10.0), id: 2))
//        addPlot(Plot(registerNumber: 1, description: "Parcela 3", realties: [], gpsPossition: GpsPossition(lattitude: 9.0, longitude: 9.0), id: 3))
//        addPlot(Plot(registerNumber: 4, description: "Parcela 4", realties: [], gpsPossition: GpsPossition(lattitude: 6.0, longitude: 6.0), id: 4))
//        addPlot(Plot(registerNumber: 3, description: "Parcela 5", realties: [], gpsPossition: GpsPossition(lattitude: 7.0, longitude: 7.0), id: 5))
//        
//        addRealty(Realty(registerNumber: 1, description: "Nehnutelnost 1", plots: [], gpsPossition: GpsPossition(lattitude: 9.0, longitude: 9.0), id: 1))
//        addRealty(Realty(registerNumber: 2, description: "Nehnutelnost 2", plots: [], gpsPossition: GpsPossition(lattitude: 10.0, longitude: 10.0), id: 2))
//        addRealty(Realty(registerNumber: 3, description: "Nehnutelnost 3", plots: [], gpsPossition: GpsPossition(lattitude: 7.0, longitude: 7.0), id: 3))
//        addRealty(Realty(registerNumber: 4, description: "Nehnutelnost 4", plots: [], gpsPossition: GpsPossition(lattitude: 6.0, longitude: 6.0), id: 4))
//        addRealty(Realty(registerNumber: 5, description: "Nehnutelnost 5", plots: [], gpsPossition: GpsPossition(lattitude: 8.0, longitude: 8.0), id: 5))
    }
    
    //MARK: PLOTS
    func addPlot(_ plot: Plot) {
        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: plot.gpsPossition.lattitude, longitude: plot.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty)
        
        
        let updatedPlot = Plot(registerNumber: plot.registerNumber,
                               description: plot.description,
                               realties: connectedRealties,
                               gpsPossition: plot.gpsPossition,
                               id: plotID)
        for realty in connectedRealties {
            realty.plots.append(updatedPlot)
        }
        plotID += 1
        plots.add(updatedPlot)
    }
    
    func getPlots(matching range: GPSRange) -> [Plot] {
        let upperBound = Plot(gpsPossition: range.upper)
        let lowerBound = Plot(gpsPossition: range.lower)
        let result = plots.findElements(lowerBound: lowerBound, upperBound: upperBound)
        return result
    }
    
    //MARK: REALTIES
    func addRealty(_ realty: Realty) {        
        let fakePlot = Plot(gpsPossition: GpsPossition(lattitude: realty.gpsPossition.lattitude, longitude: realty.gpsPossition.longitude))
        let connectedPlots = plots.findElements(lowerBound: fakePlot, upperBound: fakePlot) // here should be rectangle IMO
        let updatedRealty = Realty(registerNumber: realty.registerNumber,
                               description: realty.description,
                               plots: connectedPlots,
                               gpsPossition: realty.gpsPossition,
                               id: plotID)
        for plot in connectedPlots {
            plot.realties.append(updatedRealty)
        }
        plotID += 1 //FIXME: ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
        realties.add(updatedRealty)
    }
    
    func getRealties(matching range: GPSRange) -> [Realty] {
        let upperBound = Realty(gpsPossition: range.upper)
        let lowerBound = Realty(gpsPossition: range.lower)

        return realties.findElements(lowerBound: lowerBound, upperBound: upperBound)
    }
    
    func generate () {
        for y in 1 ... 100 {
            let plot = Plot(registerNumber: y,
                            description: String.random(length: 12),
                            realties: [],
                            gpsPossition: GpsPossition(lattitude: Double.random(in: 0 ... 10),
                                                       longitude: Double.random(in: 0 ... 10)),
                            id: y)
            
            addPlot(plot)
        }
        for y in 1 ... 100 {
            let realty = Realty(registerNumber: y,
                            description: String.random(length: 12),
                            plots: [],
                            gpsPossition: GpsPossition(lattitude: Double.random(in: 0 ... 10),
                                                       longitude: Double.random(in: 0 ... 10)),
                            id: y)
            
            addRealty(realty)
        }
    }
    
    //MARK: HELPERS
    
    func save() {
        //TODO: save
    }
    
    func load() {
        //TODO: load
    }
    

}
