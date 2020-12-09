//
//  ShowDetail.swift
//  Udajovky
//
//  Created by hladek on 09/12/2020.
//

import SwiftUI

struct LabeledText: View {
    let label: String
    let text: String
    var body: some View {
        GeometryReader{ geometry in
            HStack {
                Text("\(label):")
                    .font(.footnote)
                    .fontWeight(.light)
                ZStack {
                    Text(text)
                        .font(.caption)
                        .fontWeight(.medium)
                    RoundedRectangle(cornerRadius: geometry.size.height/2)
                        .foregroundColor(Color.black.opacity(0.1))
                }
            }
        }
        .frame(minHeight: 24)
        
    }
    
}

struct ShowDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ShowDetailViewModel
    
    

    var body: some View {
        VStack {
            Text("This property match your criteria ...").font(.headline)
                .padding(.horizontal, 20)
            LabeledText(label: "ID", text: "\(viewModel.property?.id ?? -1)")
            LabeledText(label: "Register number", text: "\(viewModel.property?.registerNumber ?? -1)")
            LabeledText(label: "Description", text: "\(viewModel.property?.description ?? "No description available")")
            LabeledText(label: "Latitude", text: "\(viewModel.property?.position.lat ?? -1)")
            LabeledText(label: "Longitude", text: "\(viewModel.property?.position.long ?? -1)")
//            HStack {
//                EditTextView(placeHolder: "Identifier ", dataHolder: $viewModel.numberHolder)
//                    .textFieldStyle(PlainTextFieldStyle())
//                Spacer().frame(width: 230)
//            }
//            EditTextView(placeHolder: "Description")
//                .textFieldStyle(PlainTextFieldStyle())
//            HStack {
//                VStack {
//                    HStack {
//                        EditTextView(placeHolder: "Lattitude", dataHolder: $viewModel.latitudeHolder)
//                            .textFieldStyle(PlainTextFieldStyle())
//
//                    }
//                    HStack {
//                        EditTextView(placeHolder: "Longitude", dataHolder: $viewModel.longitudeHolder)
//                            .textFieldStyle(PlainTextFieldStyle())
//
//                    }
//                }
//                Spacer().frame(width: 130)
//            }
            
            HStack {
                Button("OK") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedBackgroundStyle(color: .terciary))
            }
        }

        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.primary, Color.secondary]), startPoint: .top, endPoint: .bottom))
        .frame(width: 450)
    }
}

