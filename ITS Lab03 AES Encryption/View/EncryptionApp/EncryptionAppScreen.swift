import SwiftUI

struct EncryptionAppScreen: View {
    @StateObject private var viewModel = EncryptionAppScreenViewModel()
        
    var body: some View {
        VStack(alignment: .leading, spacing: .elementSpacing) {
            VStack(alignment: .leading, spacing: .labelSpacing) {
                PickerWithLabel(label: "AES Mode", selections: AESIVWithTagMode.allCases, selection: $viewModel.aesIVWithTagMode)
                PickerWithLabel(label: "Encryption Mode", selections: CryptoMode.allCases, selection: $viewModel.cryptoMode)
                
                InputWithLabel(label: "Key", sanitize: true, input: $viewModel.key, generator: viewModel.generateKey)
                
                InputWithLabel(label: "IV", sanitize: true, input: $viewModel.iv, generator: viewModel.generateIV)
                
                InputWithLabel(label: viewModel.inputHint, input: $viewModel.input)
            }
            
            Button {
                viewModel.crypt()
            } label: {
                Text(viewModel.actionButtonTitle)
            }
            .frame(maxWidth: .infinity)
            
            if let output = viewModel.output {
                VStack(alignment: .leading) {
                    Text(output)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(viewModel.output ?? "", forType: .string)
                    } label: {
                        Text("Copy")
                    }
                }
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(.red)
            }
        }
        .frame(minWidth: .screenMinWidth, minHeight: .screenMinHeight, alignment: .topLeading)
        .frame(maxWidth: .screenMaxWidth, maxHeight: .screenMaxHeight, alignment: .topLeading)
        .padding()
    }
}

#Preview {
    EncryptionAppScreen()
}

private extension CGFloat {
    static let screenMinWidth = 400.0
    static let screenMinHeight = 300.0
    static let screenMaxWidth = 500.0
    static let screenMaxHeight = 300.0
    
    static let labelSpacing = 14.0
    static let elementSpacing = 24.0
}
