import SwiftUI

struct RoundedBackgroundStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .font(.subheadline)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(40)
            .padding(.horizontal, 20)
    }
}

enum PresentableView: Identifiable {
    case placeForm, none

    var id: Int {
        hashValue
    }
}

class MainviewModel: ObservableObject {
    @Published var querry = ""
    @Published var activeSheet: PresentableView?
}

struct MainView: View {
    @Environment(\.presentationMode) var presentationMode

//    @State viewModel
    @ObservedObject var viewModel = MainviewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.querry)
            Spacer()
            HStack {
                VStack {
                    Spacer()
                        .background(Color.red)
                        .frame(width:180)
                }
                Spacer()
                Button("Pridať objekt") {
                    viewModel.activeSheet = .placeForm
                }
                .buttonStyle(RoundedBackgroundStyle(color: .accent))
                Spacer()
                .buttonStyle(RoundedBackgroundStyle(color: .accent))
                Spacer()
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
