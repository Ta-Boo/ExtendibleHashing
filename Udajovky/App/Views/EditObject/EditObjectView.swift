
import SwiftUI
struct EditObjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: EditObjectViewModel
    @State var wrongAttempt: Bool = false
    
    var body: some View {
        VStack {
            Text(viewModel.title).font(.headline)
            HStack {
                EditTextView(placeHolder: "Identifikačné číslo ", dataHolder: $viewModel.numberHolder)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer().frame(width: 230)
            }
            EditTextView(placeHolder: "Popis", dataHolder: $viewModel.descriptionHolder)
                .textFieldStyle(PlainTextFieldStyle())
            HStack {
                VStack {
                    HStack {
                        EditTextView(placeHolder: "Zemepisná širka", dataHolder: $viewModel.latitudeHolder)
                            .textFieldStyle(PlainTextFieldStyle())
                        Spacer().frame(width: 10)
                        Toggle("Vychodna", isOn: $viewModel.lattIsPositive)

                    }
                    HStack {
                        EditTextView(placeHolder: "Zemepisná dĺžka", dataHolder: $viewModel.longitudeHolder)
                            .textFieldStyle(PlainTextFieldStyle())
                        Spacer().frame(width: 10)
                        Toggle("severna", isOn: $viewModel.longIsPositive)

                    }
                }
                Spacer()
                Button("􀈑") {
                    viewModel.deleteObject()
                    self.presentationMode.wrappedValue.dismiss()

                }
                .buttonStyle(RoundedBackgroundStyle(color: Color.terciary))
            }
            
            HStack {
                Button("Zrušiť") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .terciary))
                
                Button("Potvrdiť") {
                    if viewModel.isFilled {
                        viewModel.confirm()
                        self.presentationMode.wrappedValue.dismiss()
//                        viewModel.addPDAObject()
                        
                    }
                }
                .buttonStyle(RoundedBackgroundStyle(color: .accent))
            }
        }

        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.primary, Color.secondary]), startPoint: .top, endPoint: .bottom))
        .frame(width: 450)
    }
}
