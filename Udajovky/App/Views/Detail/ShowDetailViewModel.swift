//
//  ShowDetailViewModel.swift
//  Udajovky
//
//  Created by hladek on 09/12/2020.
//

import Foundation


class ShowDetailViewModel: ObservableObject {
    @Published var property: Property?
    
    init(property: Property?) {
        self.property = property
    }
    
}
