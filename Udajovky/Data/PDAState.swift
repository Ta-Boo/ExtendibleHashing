import Foundation

class PDAState {
    static let shared = PDAState()
    var plotID = 0
    var realtyID = 0
    var plots: KDTree<Plot> = KDTree(dimensions: 2)
    var realties: KDTree<Realty> = KDTree(dimensions: 2)
    
    private init () {}
    
    //MARK: PLOTS
    func addPlot(_ plot: Plot) {
        let fakeRealty = Realty(gpsPossition: GpsPossition(lattitude: plot.gpsPossition.lattitude, longitude: plot.gpsPossition.longitude))
        let connectedRealties = realties.findElements(lowerBound: fakeRealty, upperBound: fakeRealty)
        let updatedPlot = Plot(registerNumber: plot.registerNumber,
                               description: plot.description,
                               realties: connectedRealties,
                               gpsPossition: plot.gpsPossition,
                               id: plotID)
        plotID += 1
        plots.add(updatedPlot)
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
        realtyID += 1
        realties.add(updatedRealty)
    }
    
    //MARK: HELPERS
    
    func save() {
        //TODO: save
    }
    
    func load() {
        //TODO: load
    }
    

}
