import SwiftUI
internal import UniformTypeIdentifiers

struct EncryptionAppScreen: View {
    @StateObject private var viewModel = EncryptionAppScreenViewModel()
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .elementSpacing) {
                VStack(alignment: .leading, spacing: .labelSpacing) {
                    PickerWithLabel(label: "AES Mode", selections: AESIVWithTagMode.allCases, selection: $viewModel.aesIVWithTagMode)
                    PickerWithLabel(label: "Encryption Mode", selections: CryptoMode.allCases, selection: $viewModel.cryptoMode)
                    
                    InputWithLabel(label: "Key", sanitize: true, input: $viewModel.key, generator: viewModel.generateKey)
                    
                    InputWithLabel(label: "IV", sanitize: true, input: $viewModel.iv, toggle: $viewModel.useIV, generator: viewModel.generateIV)
                    
                    InputWithLabel(label: viewModel.inputHint, input: $viewModel.input)
                }
                
                HStack {
                    Button {
                        viewModel.cipherText()
                    } label: {
                        Text(viewModel.actionButtonTitle)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.fileCryptoMode = .encrypt
                        viewModel.isFileImporterPresent = true
                    } label: {
                        Text("Encode file")
                    }
                    
                    Button {
                        viewModel.fileCryptoMode = .decrypt
                        viewModel.isFileImporterPresent = true
                    } label: {
                        Text("Decode file")
                    }
                }
                .fileImporter(
                    isPresented: $viewModel.isFileImporterPresent,
                    allowedContentTypes: [.item],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        guard let selectedFile = try result.get().first else { return }
                        let data = try Data(contentsOf: selectedFile)
                        
                        let granted = selectedFile.startAccessingSecurityScopedResource()
                        defer { if granted { selectedFile.stopAccessingSecurityScopedResource() } }
                        
                        
                        switch viewModel.fileCryptoMode {
                        case .encrypt:
                            viewModel.encryptFile(of: selectedFile, data: data)
                        case .decrypt:
                            viewModel.decryptFile(of: selectedFile, data: data)
                        case .none:
                            return
                        }
                    } catch {
                        print(error)
                    }
                }
                
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
            .padding()
        }
        .frame(minWidth: .screenMinWidth, minHeight: .screenMinHeight)
        .frame(maxWidth: .screenMaxWidth)
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
    
    static let labelSpacing = 14.0
    static let elementSpacing = 24.0
}
