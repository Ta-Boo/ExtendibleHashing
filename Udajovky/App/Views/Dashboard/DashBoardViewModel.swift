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
    
    
    var propertyToBeEdited: Property?
    
    
    
    func generate() {
        PDAState.shared.generate()
        fetchAllData()
    }
    
    func fetchAllData() {
        allData = PDAState.shared.allData
        
    }
    
    func findObjects() {
    }
    
    func setUpEditViewModel(item: Property) {
        activeSheet = .detail
        self.propertyToBeEdited = item
    }
    
    func save() {
        PDAState.shared.save()
    }
    
//    func load() {
//        PDAState.shared.load()
//    }
    
}

