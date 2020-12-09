import SwiftUI



class UIBlock<T>: Identifiable  where T: Hashable, T: Storable{
    internal init(id: Int, block: Block<T>) {
        self.id = id
        self.block = block
    }
    
    let id: Int
    let block: Block<T>
}
class DashBoardViewModel: ObservableObject {
    @Published var activeSheet: PresentableView?
    
    @Published var idHolder: String = ""
    
    var isFilled: Bool {
        get {
            return !idHolder.isEmpty
        }
    }

    @Published var allData: AllData<Property> = AllData(mainAddressary: [], overflowAddressary: [], mainFreeAddresses: [], overflowAddresses: [], mainBlocks: [], overflowBlocks: [])
    
    
    var propertyToBeShown: Property? {
        get {
            return PDAState.shared.find(Property(registerNumber: Int(idHolder)!, id: Int(idHolder)!, description: "", position: GPS(lat: 0, long: 0)))
        }
    }
    
    
    
    func generate() {
        PDAState.shared.generate()
        fetchAllData()
    }
    
    func fetchAllData() {
        allData = PDAState.shared.allData
    }
    
    func delete() {
        PDAState.shared.delete(Property(registerNumber: Int(idHolder)!, id: Int(idHolder)!, description: "", position: GPS(lat: 0, long: 0)))
        fetchAllData()
    }
    
    func findObjects() {
    }
    
    func setUpEditViewModel(item: Property) {
        activeSheet = .detail
//        self.propertyToBeEdited = item
    }
    
    func save() {
        PDAState.shared.save()
    }
    
//    func load() {
//        PDAState.shared.load()
//    }
    
}

