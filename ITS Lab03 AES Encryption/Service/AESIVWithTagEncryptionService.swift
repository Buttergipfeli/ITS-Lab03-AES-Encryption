import Foundation
import CryptoSwift
import Security

// DOC: https://cryptoswift.io/#aes-gcm
final class AESIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol {
    func encrypt(text: String, mode: AESIVWithTagMode, key: String) throws -> String {
        let blockMode = mode.blockMode(messageLength: text.count, encrypt: true)
        
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        let encryptedBytes = try Array(aes.encrypt(text.bytes))
        
        return String(decoding: encryptedBytes, as: UTF8.self)
    }
    
    func decrypt(encryptedText: String, mode: AESIVWithTagMode, key: String) throws -> String {
        let blockMode = mode.blockMode(messageLength: encryptedText.count, encrypt: false)
        
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        let decryptedBytes = try Array(aes.decrypt(encryptedText.bytes))
        
        return String(decoding: decryptedBytes, as: UTF8.self)
    }
}
