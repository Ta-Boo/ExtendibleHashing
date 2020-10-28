//
//  PlaceForm.swift
//  Udajovky
//
//  Created by hladek on 25/10/2020.
//

import SwiftUI

struct EditTextView: View {
    let placeHolder: String
    @Binding var dataHolder: String
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 30)
            TextField(placeHolder, text: $dataHolder)
                .textFieldStyle(PlainTextFieldStyle())
                
        }
        .frame(height: 30)
        .background(Color.primary)
        .cornerRadius(50)
        .padding()
    }
}


class PlaceFormViewModel: ObservableObject {
    @Published var nameHolder: String = ""
    @Published var widthHolder: String = ""
    @Published var lengthHolder: String = ""
    @Published var isParcel = true

}

struct PlaceFormView: View {
    @Environment(\.presentationMode) var presentationMode

    
    @ObservedObject var viewModel = PlaceFormViewModel()

    var body: some View {
        VStack {
            Spacer()
            EditTextView(placeHolder: "Nazov", dataHolder: $viewModel.nameHolder)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
            EditTextView(placeHolder: "Zemepisna sirka", dataHolder: $viewModel.widthHolder)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
            EditTextView(placeHolder: "Zemepisna dlzka", dataHolder: $viewModel.lengthHolder)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
            Toggle("Parcela", isOn: $viewModel.isParcel)
            
            Spacer()
            HStack {
                Button("Dismiss") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .terciary))
                
                Button("Add") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .accent))
            }
            
            
                
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.primary, Color.secondary]), startPoint: .top, endPoint: .bottom))
        .frame(width: 450)
    }
}
