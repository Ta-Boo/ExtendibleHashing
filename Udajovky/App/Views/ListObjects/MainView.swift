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
    @ObservedObject var viewModel = MainviewModel()
    @State var wrongAttempt: Bool = false

    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    List(){
                        Section(header: Text("Parcely").font(.title).foregroundColor(.white)){
                            var grey = false
                            ForEach(viewModel.foundPlots) { item in
                                VStack {
                                    HStack {
                                        Text("\(item.registerNumber)")
                                        Spacer()
                                        Text(item.description)
                                        Spacer()
                                        Text("[\(item.gpsPossition.lattitude),\(item.gpsPossition.longitude)]")
                                        Spacer()
                                        Text("Nehnutelnosti: \(item.realtiesDescription)")
                                        Spacer()
                                    }
                                }
                                .onTapGesture{
                                    viewModel.setUpEditViewModel(item: item)
                                }
                                Rectangle()
                                    .frame(width: geometry.size.width / 3 * 1.9, height: 1)
                            }
                        }
                        Spacer().frame(height: 30)
                        Section(header: Text("Nehnutelnosti").font(.title).foregroundColor(.white)){
                            ForEach(viewModel.foundRealties) { item in
                                VStack {
                                    HStack {
                                        Text("\(item.registerNumber)")
                                        Spacer()
                                        Text(item.description)
                                        Spacer()
                                        Text("[\(item.gpsPossition.lattitude),\(item.gpsPossition.longitude)]")
                                        Spacer()
                                        Text("Nehnutelnosti: \(item.plotsDescription)")
                                        Spacer()
                                    }
                                }
                                .onTapGesture{
                                    viewModel.setUpEditViewModel(item: item)
                                }
                                Rectangle()
                                    .frame(width: geometry.size.width / 3 * 1.9, height: 1)
                            }
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
                            }
                            HStack{
                                Spacer()
                                Button("􀊫") {
                                    viewModel.findObjects()
                                }
                                .buttonStyle(RoundedBackgroundStyle(color: viewModel.isFilled ? Color.accent : Color.terciary))
                                .frame(width: 75)
                            }
                            Button("Generate") {
                                viewModel.generate()
                            }
                            Image("owl")
                                .resizable()
                                .scaledToFit()
//                                .offset(x: - (geometry.size.width / 9)
                                .frame(width: geometry.size.width / 8)
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
        .background(LinearGradient(gradient: Gradient(colors: [Color.secondary, Color.primary]), startPoint: .top, endPoint: .bottom))
        .sheet(item: $viewModel.activeSheet) { item in
            switch item {
            case .none:
                EmptyView()
            case .placeForm:
                PlaceFormView()
            case .detail:
                 
                EditObjectView(viewModel: viewModel.editObjectViewModel)
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