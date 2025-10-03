import SwiftUI

struct InputWithLabel: View {
    private let label: String
    private let sanitize: Bool
    @Binding private var input: String
    @Binding private var toggle: Bool
    private let hasToggle: Bool
    private let generator: (() -> Void)?
    
    private var isDisabled: Bool {
        hasToggle && !toggle
    }
    
    init(label: String, sanitize: Bool = false, input: Binding<String>, toggle: Binding<Bool>? = nil, generator: (() -> Void)? = nil) {
        self.label = label
        self.sanitize = sanitize
        _input = input
        self.generator = generator
        hasToggle = toggle != nil
        _toggle = toggle ?? .constant(false)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                
                Spacer()
                
                if hasToggle {
                    Toggle("Allow customising", isOn: $toggle)
                }
            }
            
            TextField(text: $input) {
                Text(label)
            }
            .disabled(isDisabled)
            
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
                .disabled(isDisabled)
            }
        }
        .onChange(of: input) { _, newValue in
            guard sanitize else { return }
            input = input.sanitizeToUTF8()
        }
    }
}
