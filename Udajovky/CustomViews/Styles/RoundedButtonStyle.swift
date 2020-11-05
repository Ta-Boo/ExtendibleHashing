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
