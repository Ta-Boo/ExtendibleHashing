//
//  PlaceForm.swift
//  Udajovky
//
//  Created by hladek on 25/10/2020.
//

import SwiftUI

//class PlaceInputDataWrapper {
//
//
//    var gpsPossition: GpsPossition?
//    var registerNumber: Int?
//    var description: String?
//    var isPlot: Bool?
//
//    init() {}
//    internal init(gpsPossition: GpsPossition, registerNumber: Int, description: String, isPlot: Bool) {
//        self.gpsPossition = gpsPossition
//        self.registerNumber = registerNumber
//        self.description = description
//        self.isPlot = isPlot
//    }
//}

class PlaceFormViewModel: ObservableObject {
    @Published var numberHolder: String = ""
    @Published var descriptionHolder: String = ""
    @Published var latitudeHolder: String = ""
    @Published var longitudeHolder: String = ""
    @Published var isParcel = true

    var isFilled: Bool {
        return !numberHolder.isEmpty &&
                !descriptionHolder.isEmpty &&
                !latitudeHolder.isEmpty &&
                !longitudeHolder.isEmpty
    }
    
    func addPDAObject() {
        if isParcel {
            PDAState.shared.addRealty(Realty(registerNumber: Int(numberHolder)!,
                                           description: descriptionHolder,
                                           plots: [],
                                           gpsPossition: GpsPossition(lattitude: Int(latitudeHolder)!, longitude: Int(longitudeHolder)!),
                                           id: 0))
        } else {
            PDAState.shared.addPlot(Plot(registerNumber: Int(numberHolder)!,
                                         description: descriptionHolder,
                                         realties: [],
                                         gpsPossition: GpsPossition(lattitude: Int(latitudeHolder)!, longitude: Int(longitudeHolder)!),
                                         id: 0))
        }
    }
    
}

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
//                        result = viewModel.result!
                        
                    } else {
                        self.wrongAttempt.toggle()
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
