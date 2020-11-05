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
    
    func findObjects() {
        let lowerBound = GpsPossition(lattitude: Double(latitudeHolderA)!, longitude: Double(longitudeHolderA)!)
        let upperBound = GpsPossition(lattitude: Double(latitudeHolderB) ?? Double(latitudeHolderA)!, longitude: Double(longitudeHolderB) ?? Double(longitudeHolderA)!)
        foundPlots = PDAState.shared.getPlots(matching: GPSRange(upper: upperBound, lower: lowerBound))
        foundRealties = PDAState.shared.getRealties(matching: GPSRange(upper: upperBound, lower: lowerBound))
    }
}
