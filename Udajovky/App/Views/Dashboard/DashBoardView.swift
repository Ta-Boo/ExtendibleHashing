import SwiftUI
enum PresentableView: Identifiable {
    case placeForm, detail, none
    
    var id: Int {
        hashValue
    }
}

struct Listable: Identifiable {
    let id: Int
    let text: String
}



struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = DashBoardViewModel()
    @State var wrongAttempt: Bool = false
    @State private var showingAlert = false

    
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    VStack {
                        HStack {
                            Text("Blocks in main: \(viewModel.allData.mainBlocks.count)")
                            Spacer()
                            Text("Blocks in owerflow: \(viewModel.allData.overflowBlocks.count)")
                                .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            List() {
                                Section(header: Text("Main").font(.title).foregroundColor(.white)) {
                                        ForEach(viewModel.allData.mainAddressary.map({$0.toString()}), id: \.self) { address in
                                            Text(String(address)).lineLimit(nil)
                                        }
                                    Text("Blocks:").font(.headline).foregroundColor(.white)
                                    ForEach(viewModel.allData.mainBlocks.map({ $0.toString() }), id: \.self) { address in
                                        Text(String(address))
                                    }
                                }
                            }
                            .listStyle(SidebarListStyle())
                            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(16)

                            List() {
                                Section(header: Text("Owerflow").font(.title).foregroundColor(.white)) {
                                        ForEach(viewModel.allData.overflowAddressary.map({$0.desc}), id: \.self) { address in
                                            Text(String(address))
                                        }
                                        Text("Blocks:").font(.headline).foregroundColor(.white)
                                        ForEach(viewModel.allData.overflowBlocks.map({ $0.toString() }), id: \.self) { address in
                                            Text(String(address))
                                        }
                                }
                            }
                            .listStyle(SidebarListStyle())
                            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(16)
                        }
//                        .padding(.vertical, 40)
                    }
                    .frame(width: geometry.size.width / 4 * 3, height: geometry.size.height)
                    
                    
                    Spacer()
                    VStack {
                        VStack {
                            HStack{
                                Text("Find object")
                                Spacer()
                            }
                            HStack {
                                EditTextView(placeHolder: "ID of an object", dataHolder: $viewModel.idHolder)
                                    .textFieldStyle(PlainTextFieldStyle())
                                Spacer().frame(width: 10)
                                
                            }
                            
                            Spacer().frame(height: 32)
                            
                            
                            HStack{
                                Spacer()
                                Button("􀈑 Delete") {
                                    viewModel.delete()
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: viewModel.isFilled ? Color.accent : Color.terciary))
//                                .frame(width: 75)
                                Button("􀊫 Find") {
                                    viewModel.activeSheet = .detail
//                                    viewModel.findObjects()
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: viewModel.isFilled ? Color.accent : Color.terciary))
//                                .frame(width: 75)
                            }
                            
                            Spacer()
                            HStack {
                                Spacer()
                                Image("owl")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width / 8)
                            }
                            Button("Generate") {
                                viewModel.generate()
                            }
                            .buttonStyle(RoundedBackgroundStyle(color:Color.secondary))
                            HStack {
                                Button("Save") {
                                    viewModel.save()
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: Color.secondary))
                                
                                Button("Load") {
                                    viewModel.load()
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: Color.secondary))
                            }
                            .padding(.top, 8)
                            Button("Debug data") {
                                viewModel.fetchAllData()
                            }
                            .buttonStyle(RoundedBackgroundStyle(color:Color.secondary))
                            .padding(.top, 8)
                            
                        }
                        Spacer()
                        Button("Add property") {
                            viewModel.activeSheet = .placeForm
                        }
                        .buttonStyle(RoundedBackgroundStyle(color: .accent))
                        
                    }
                    .frame(width: geometry.size.width / 4)
//                    Spacer()
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(LinearGradient(gradient: Gradient(colors: [Color.secondary, Color.primary]), startPoint: .top, endPoint: .bottom))
        .sheet(item: $viewModel.activeSheet) { item in
            switch item {
            case .none:
                EmptyView()
            case .placeForm:
                PlaceFormView()
            case .detail:
                ShowDetail(viewModel: ShowDetailViewModel(property: viewModel.propertyToBeShown))
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDevice(PreviewDevice(rawValue: "Mac"))
    }
}
