import Foundation
import CryptoSwift
import Security

// DOC: https://cryptoswift.io/#aes-gcm
final class AESIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol {
    func encrypt(text: String, mode: AESIVWithTag, key: String) throws -> String {
        let plaintextBytes = Array(text.utf8)
        let blockMode = mode.blockMode(messageLength: plaintextBytes.count, mode: .encrypt)
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        let encryptedBytes = try aes.encrypt(plaintextBytes)
        
        return Data(encryptedBytes).base64EncodedString()
    }
    
    func decrypt(encryptedText: String, mode: AESIVWithTag, key: String) throws -> String {
        guard let cipherData = Data(base64Encoded: encryptedText) else { throw CryptoError.decodingFailed }
        let cipherBytes = [UInt8](cipherData)
        let blockMode = mode.blockMode(messageLength: key.bytes.count, mode: .decrypt)
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        let decryptedBytes = try aes.decrypt(cipherBytes)
        
        if let plainText = String(bytes: decryptedBytes, encoding: .utf8) {
            return plainText
        } else {
            throw CryptoError.decodingFailed
        }
    }
}
