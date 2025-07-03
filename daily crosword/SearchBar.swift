import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit { onSearch() }
            Button("Search") { onSearch() }
        }
        .padding()
    }
} 