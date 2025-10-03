import SwiftUI

struct InputWithLabel: View {
    let label: String
    var sanitize = false
    @Binding var input: String
    var generator: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            
            TextField(text: $input) {
                Text(label)
            }
            
            if let generator {
                HStack {
                    Button {
                        generator()
                    } label: {
                        Text("Generate")
                    }
                    
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(input, forType: .string)
                    } label: {
                        Text("Copy")
                    }
                }
            }
        }
        .onChange(of: input) { _, newValue in
            guard sanitize else { return }
            input = input.sanitizeToUTF8()
        }
    }
}
