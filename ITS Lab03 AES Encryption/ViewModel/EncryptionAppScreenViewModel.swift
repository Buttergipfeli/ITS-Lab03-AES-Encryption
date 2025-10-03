import Combine
import Foundation
import CryptoSwift

final class EncryptionAppScreenViewModel: ObservableObject {
    private let aesIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol
    
    @Published var aesIVWithTagMode: AESIVWithTagMode = .gcm
    @Published var cryptoMode: CryptoMode = .encrypt
    @Published var input: String = "Maschine"
    @Published var key: String = "abcdefabcdefabcdabcdefabcdefabcd"
    @Published var iv: String = "adsfjlkaasdfjd"
    
    @Published private(set) var output: String?
    @Published private(set) var errorMessage: String?
    
    var inputHint: String {
        "Text to \(cryptoMode.rawValue) with \(aesIVWithTagMode.rawValue.uppercased())"
    }
    
    var actionButtonTitle: String {
        "\(cryptoMode.rawValue.firstLetterUppercased()) with \(aesIVWithTagMode.rawValue.uppercased())"
    }
    
    init(aesIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol = AESIVWithTagEncryptionService()) {
        self.aesIVWithTagEncryptionService = aesIVWithTagEncryptionService
    }
    
    func crypt() {
        guard Int.allowedKeySizes.contains(key.bytes.count) else {
            output = nil
            errorMessage = "Your key must be \(Int.allowedKeySizes) bytes long."
            return
        }
        guard Int.ivRange.contains(iv.bytes.count) else {
            output = nil
            errorMessage = "IV must be in \(Int.ivRange)"
            return
        }
                
        let mode = AESIVWithTag(iv: iv, mode: aesIVWithTagMode)
        
        do {
            switch cryptoMode {
            case .encrypt:
                output = try aesIVWithTagEncryptionService.encrypt(text: input, mode: mode, key: key)
            case .decrypt:
                output = try aesIVWithTagEncryptionService.decrypt(encryptedText: input, mode: mode, key: key)
            }
            
            errorMessage = nil
        } catch {
            print("###Error: \(error)")
            errorMessage = "An unknown error occured."
            output = nil
        }
    }
    
    func generateIV() {
        iv = String(UUID().uuidString.prefix(.ivGenLength))
    }
    
    func generateKey() {
        key = String(UUID().uuidString.prefix(.keyGenLength))
    }
}

private extension Int {
    static let allowedKeySizes = [16, 24, 32]
    static let ivRange = 7...13
    static let keyGenLength: Int = 32
    static let ivGenLength: Int = 12
}
