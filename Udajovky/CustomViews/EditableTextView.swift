//
//  EditableTextView.swift
//  Udajovky
//
//  Created by hladek on 04/11/2020.
//

import SwiftUI

struct EditTextView: View {
    let placeHolder: String
    @Binding var dataHolder: String
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 22)
            TextField(placeHolder, text: $dataHolder)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
                .frame(width: 22)
            
        }
        .frame(height: 30)
        .background(Color.primary)
        .cornerRadius(15)
    }
}
