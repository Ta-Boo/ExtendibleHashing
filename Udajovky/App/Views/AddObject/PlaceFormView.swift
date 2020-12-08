
import SwiftUI
struct PlaceFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = PlaceFormViewModel()
    @State var wrongAttempt: Bool = false
    
    var body: some View {
        VStack {
            Text("Insert data about property...").font(.headline)
            HStack {
                EditTextView(placeHolder: "Identifier ", dataHolder: $viewModel.numberHolder)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer().frame(width: 230)
            }
            EditTextView(placeHolder: "Description", dataHolder: $viewModel.descriptionHolder)
                .textFieldStyle(PlainTextFieldStyle())
            HStack {
                VStack {
                    HStack {
                        EditTextView(placeHolder: "Lattitude", dataHolder: $viewModel.latitudeHolder)
                            .textFieldStyle(PlainTextFieldStyle())

                    }
                    HStack {
                        EditTextView(placeHolder: "Longitude", dataHolder: $viewModel.longitudeHolder)
                            .textFieldStyle(PlainTextFieldStyle())

                    }
                }
                Spacer().frame(width: 130)
            }
            
            HStack {
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .terciary))
                
                Button("Add") {
                    if viewModel.isFilled {
                        self.presentationMode.wrappedValue.dismiss()
                        viewModel.addPDAObject()
                        
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
