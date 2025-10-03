import Combine
import Foundation
import CryptoSwift

final class EncryptionAppScreenViewModel: ObservableObject {
    private let aesIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol
    
    @Published var aesIVWithTagMode: AESIVWithTagMode = .gcm
    @Published var cryptoMode: CryptoMode = .encrypt
    @Published var input: String = ""
    @Published var key: String = ""
    @Published var iv: String = ""
    @Published var useIV = false
    @Published var fileCryptoMode: CryptoMode? = nil
    @Published var isFileImporterPresent = false
    
    @Published private(set) var output: String?
    @Published private(set) var errorMessage: String?
    
    var inputHint: String {
        "Text to \(cryptoMode.rawValue) with \(aesIVWithTagMode.rawValue.uppercased())"
    }
    
    var actionButtonTitle: String {
        "\(cryptoMode.rawValue.firstLetterUppercased()) text with \(aesIVWithTagMode.rawValue.uppercased())"
    }
    
    private var aesIVWithTag: AESIVWithTag {
        AESIVWithTag(iv: useIV ? iv : nil, mode: aesIVWithTagMode)
    }
    
    init(aesIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol = AESIVWithTagEncryptionService()) {
        self.aesIVWithTagEncryptionService = aesIVWithTagEncryptionService
    }
    
    func cipherText() {
        guard validateKeyAndIV() else { return }
                
        do {
            switch cryptoMode {
            case .encrypt:
                output = try aesIVWithTagEncryptionService.encrypt(text: input, mode: aesIVWithTag, key: key)
            case .decrypt:
                output = try aesIVWithTagEncryptionService.decrypt(encryptedText: input, mode: aesIVWithTag, key: key)
            }
            
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }
    
    func encryptFile(of selectedFileURL: URL, data: Data) {
        guard validateKeyAndIV() else { return }
        do {
            let encryptedBytes = try aesIVWithTagEncryptionService.encrypt(bytes: Array(data), mode: aesIVWithTag, key: key)
            writeCipheredFile(originalFileURL: selectedFileURL, bytes: encryptedBytes)
            
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }
    
    func decryptFile(of selectedFileURL: URL, data: Data) {
        guard validateKeyAndIV() else { return }
        do {
            let decryptedBytes = try aesIVWithTagEncryptionService.decrypt(cipherBytes: Array(data), mode: aesIVWithTag, key: key)
            writeCipheredFile(originalFileURL: selectedFileURL, bytes: decryptedBytes)
            
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }
    
    func generateIV() {
        iv = String(UUID().uuidString.prefix(.ivGenLength))
    }
    
    func generateKey() {
        key = String(UUID().uuidString.prefix(.keyGenLength))
    }
    
    private func writeCipheredFile(originalFileURL: URL, bytes: [UInt8]) {
        let folderURL = originalFileURL.deletingLastPathComponent()
        let fileName = originalFileURL.deletingPathExtension().lastPathComponent
        let fileExtension = originalFileURL.pathExtension
        
        let newFileName = fileExtension.isEmpty
        ? "\(fileName)-\(fileCryptoMode?.rawValue ?? "")"
        : "\(fileName)-\(fileCryptoMode?.rawValue ?? "").\(fileExtension)"
        
        let newFileURL = folderURL.appendingPathComponent(newFileName)
        
        let data = Data(bytes)
        
        do {
            try data.write(to: newFileURL, options: .atomic)
        } catch {
            errorMessage = "An error happened while trying to write a new file."
        }
    }
    
    private func handleError(_ error: Error) {
        if "\(error)" == "fail" {
            errorMessage = "The decoding or encoding failed. Probably the key or iv are wrong."
        } else {
            errorMessage = "An unknown error occured: \(error)."
        }
        output = nil
    }
    
    private func validateKeyAndIV() -> Bool {
        guard Int.allowedKeySizes.contains(key.bytes.count) else {
            output = nil
            errorMessage = "Your key must be \(Int.allowedKeySizes) bytes long."
            return false
        }
        guard !useIV || Int.ivRange.contains(iv.bytes.count) else {
            output = nil
            errorMessage = "IV must be in \(Int.ivRange)"
            return false
        }
        
        return true
    }
}

private extension Int {
    static let allowedKeySizes = [16, 24, 32]
    static let ivRange = 7...13
    static let keyGenLength: Int = 32
    static let ivGenLength: Int = 12
}
