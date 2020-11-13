import SwiftUI


class MainviewModel: ObservableObject {
    @Published var querry = ""
    @Published var activeSheet: PresentableView?
    
    @Published var latitudeHolderA: String = ""
    @Published var longitudeHolderA: String = ""
    @Published var latitudeHolderB: String = ""
    @Published var longitudeHolderB: String = ""
    
    @Published var pointSearch = false
    
    @Published var foundPlots: [Plot] = []
    @Published var foundRealties: [Realty] = []
    
    
    @Published var lattIsPositiveA = true
    @Published var longIsPositiveA = true
    @Published var lattIsPositiveB = true
    @Published var longIsPositiveB = true
    
    var plotToBeEdited: Plot?
    var realtyToBeEdited: Realty?
    
    var editObjectViewModel : EditObjectViewModel {
        if let plot = plotToBeEdited {
            return EditObjectViewModel(title: "Uprav parcelu",plot: plot)
        } else {
            return EditObjectViewModel(title: "Uprav nehnutelnost", realty: realtyToBeEdited!)
        }
    }
    
    var isFilled: Bool {
        
        if pointSearch {
            return !latitudeHolderA.isEmpty &&
                !longitudeHolderA.isEmpty
        } else {
            return !latitudeHolderA.isEmpty &&
                !longitudeHolderA.isEmpty &&
                !latitudeHolderB.isEmpty &&
                !longitudeHolderB.isEmpty
        }
    }
    
    func generate() {
        PDAState.shared.generate()
    }
    
    func findObjects() {
        let latMultiplierA: Double = lattIsPositiveA ? 1 : -1
        let longMultiplierA: Double = longIsPositiveA ? 1 : -1
        let latMultiplierB: Double = lattIsPositiveB ? 1 : -1
        let longMultiplierB: Double = longIsPositiveB ? 1 : -1
        if isFilled {
            let lowerBound = GpsPossition(lattitude: Double(latitudeHolderA)! * latMultiplierA , longitude: Double(longitudeHolderA)! * longMultiplierA)
            let upperBound = GpsPossition(lattitude: Double(latitudeHolderB)! * latMultiplierB , longitude: Double(longitudeHolderB)! * longMultiplierB)
//            let lowerBound = GpsPossition(lattitude: Double(latitudeHolderA)!, longitude: Double(longitudeHolderA)!)
//            let upperBound = GpsPossition(lattitude: Double(latitudeHolderB) ?? Double(latitudeHolderA)!, longitude: Double(longitudeHolderB) ?? Double(longitudeHolderA)!)
            foundPlots = PDAState.shared.getPlots(matching: GPSRange(upper: upperBound, lower: lowerBound))
            foundRealties = PDAState.shared.getRealties(matching: GPSRange(upper: upperBound, lower: lowerBound))
        } else {
            let lowerBound = GpsPossition(lattitude: 0 - Double.greatestFiniteMagnitude, longitude: 0 - Double.greatestFiniteMagnitude)
            let upperBound = GpsPossition(lattitude: Double.greatestFiniteMagnitude, longitude: Double.greatestFiniteMagnitude)
            foundPlots = PDAState.shared.getPlots(matching: GPSRange(upper: upperBound, lower: lowerBound))
            foundRealties = PDAState.shared.getRealties(matching: GPSRange(upper: upperBound, lower: lowerBound))
        }
    }
    
    func setUpEditViewModel(item: Realty) {
        activeSheet = .detail
        self.realtyToBeEdited = item
        self.plotToBeEdited = nil
    }
    
    func setUpEditViewModel(item: Plot) {
        activeSheet = .detail
        self.plotToBeEdited = item
        self.realtyToBeEdited = nil
    }
    
    func save() {
        PDAState.shared.save()
    }
    
    func load() {
        PDAState.shared.load()
    }
    
}

