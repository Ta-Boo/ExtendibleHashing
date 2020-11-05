import SwiftUI
enum PresentableView: Identifiable {
    case placeForm, none
    
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
    
    //    @State viewModel
    @ObservedObject var viewModel = MainviewModel()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    List(){
                        Section(header: Text("Properties").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)){
                            ForEach(viewModel.items) { item in
                                Text(item.text)
                            }
                        }
                        Spacer().frame(height: 30)
                        Section(header: Text("Royalties").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)){
                            ForEach(viewModel.items.reversed()) { item in
                                Text(item.text)
                            }.onDelete(perform: { indexSet in
                                
                            })
                        }
                        
                    }
                    .listStyle(SidebarListStyle())
                    .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(16)
                    .frame(width: geometry.size.width / 3 * 2, height: geometry.size.height)
                    .padding(.vertical, 40)
                    
                    
                    Spacer()
                    VStack {
                        Spacer()
                        Button("Pridať objekt") {
                            viewModel.activeSheet = .placeForm
                        }
                        .buttonStyle(RoundedBackgroundStyle(color: .accent))
                    }
                    .frame(width: geometry.size.width / 3)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.secondary, Color.primary]), startPoint: .top, endPoint: .bottom))
        .sheet(item: $viewModel.activeSheet) { item in
            switch item {
            case .none:
                EmptyView()
            case .placeForm:
                PlaceFormView()
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
