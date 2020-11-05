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

//struct ShakeEffect: GeometryEffect {
//    var distance: CGFloat = 6
//    var shakes: CGFloat = 4
//    var data: Bool
//    func effectValue(size: CGSize) -> ProjectionTransform {
//        ProjectionTransform(CGAffineTransform(translationX: distance * sin(data ? 2.0 : 0.0 * .pi * shakes ), y: 0))
//    }
//}
struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    
    //    @State viewModel
    @ObservedObject var viewModel = MainviewModel()
    @State var wrongAttempt: Bool = false

    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    List(){
                        Section(header: Text("Parcely").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)){
                            ForEach(viewModel.foundPlots) { item in
                                HStack {
                                    Text("\(item.registerNumber)")
                                    Text(item.description)
                                    Text("[\(item.gpsPossition.lattitude),\(item.gpsPossition.longitude)]")
                                    Text("Nehnutelnosti: \(item.realties.count)")
                                }
                            }
                        }
                        Spacer().frame(height: 30)
                        Section(header: Text("Nehnutelnosti").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)){
                            ForEach(viewModel.foundRealties) { item in
                                HStack {
                                    Text("\(item.registerNumber)")
                                    Text(item.description)
                                    Text("[\(item.gpsPossition.lattitude),\(item.gpsPossition.longitude)]")
                                    Text("Parcely: \(item.plots.count)")

                                }
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
                        VStack {
                            HStack{
                                Text("GPS bod A")
                                Spacer()
                            }
                            EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.latitudeHolderA)
                                .textFieldStyle(PlainTextFieldStyle())
                            EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.longitudeHolderA)
                                .textFieldStyle(PlainTextFieldStyle())
                            Spacer().frame(height: 32)
                            Toggle("Bodové vyhľadávanie", isOn: $viewModel.pointSearch)

                            
                            if !viewModel.pointSearch {
                                VStack {
                                    HStack{
                                        Text("GPS bod B")
                                        Spacer()
                                    }
                                    EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.latitudeHolderB)
                                    EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.longitudeHolderB)
                                }
                                .animation(.default).transition(AnyTransition.opacity.animation(.easeInOut))
                            }
                            HStack{
                                Spacer()
                                Button("􀊫") {
                                    if viewModel.isFilled {
                                        viewModel.findObjects()
                                    }
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: viewModel.isFilled ? Color.accent : Color.terciary))
                                .frame(width: 75)
                            }
                        }
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
