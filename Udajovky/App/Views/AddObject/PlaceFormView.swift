
import SwiftUI
struct PlaceFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = PlaceFormViewModel()
    @State var wrongAttempt: Bool = false
    
    var body: some View {
        VStack {
            Text("Údaje o vkladanom objekte").font(.headline)
            HStack {
                EditTextView(placeHolder: "Identifikačné číslo ", dataHolder: $viewModel.numberHolder)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer().frame(width: 230)
            }
            EditTextView(placeHolder: "Popis", dataHolder: $viewModel.descriptionHolder)
                .textFieldStyle(PlainTextFieldStyle())
            HStack {
                VStack {
                    EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.latitudeHolder)
                        .textFieldStyle(PlainTextFieldStyle())
                    EditTextView(placeHolder: "Zemepisná dĺžka", dataHolder: $viewModel.longitudeHolder)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Spacer().frame(width: 130)
            }
            Toggle("Parcela", isOn: $viewModel.isParcel)
            
            HStack {
                Button("Zrušiť") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .terciary))
                
                Button("Pridať") {
                    if viewModel.isFilled {
                        self.presentationMode.wrappedValue.dismiss()
                        viewModel.addPDAObject()
                        
                    } else {
                        wrongAttempt.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            wrongAttempt.toggle()
                        }
                    }
                    
                }
                .buttonStyle(RoundedBackgroundStyle(color: .accent))
            }
        }
        .offset(x: wrongAttempt ? -10 : 0)
        .animation(Animation.linear(duration: 0.05).repeatCount(3))
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.primary, Color.secondary]), startPoint: .top, endPoint: .bottom))
        .frame(width: 450)
    }
}
