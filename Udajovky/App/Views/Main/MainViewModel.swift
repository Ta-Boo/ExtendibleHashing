import SwiftUI

class MainviewModel: ObservableObject {
    @Published var querry = ""
    @Published var activeSheet: PresentableView?
    let items = [Listable(id: 1, text: "Prvy"),
                 Listable(id: 2, text: "Prvy"),
                 Listable(id: 3, text: "Prvy"),
                 Listable(id: 3, text: "Prvy"),
                 Listable(id: 4, text: "Prvy"),
                 Listable(id: 5, text: "5"),
                 Listable(id: 6, text: "Prvy"),
                 Listable(id: 7, text: "Prvy"),
                 Listable(id: 8, text: "Prvy"),
                 Listable(id: 9, text: "Prvy"),
                 Listable(id: 10, text: "10"),
                 Listable(id: 12, text: "Prvy"),
                 Listable(id: 13, text: "Prvy"),
                 Listable(id: 14, text: "14"),
                 Listable(id: 15, text: "Prvy"),
                 Listable(id: 16, text: "Prvy"),
                 Listable(id: 12, text: "posledny")]
}
