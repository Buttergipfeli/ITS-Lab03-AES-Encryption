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
        let encryptedBytesWithIVPrefix = (mode.usedCustomIV ? [] : mode.iv) + encryptedBytes
        
        return Data(encryptedBytesWithIVPrefix).base64EncodedString()
    }
    
    func decrypt(encryptedText: String, mode: AESIVWithTag, key: String) throws -> String {
        guard let cipherData = Data(base64Encoded: encryptedText) else { throw CryptoError.decodingFailed }
        let cipherBytes = Array(cipherData)
        let cipherBytesWithoutIVPrefix: [UInt8]
        var newMode = mode
        if mode.usedCustomIV {
            cipherBytesWithoutIVPrefix = cipherBytes
        } else {
            cipherBytesWithoutIVPrefix = Array(cipherBytes.dropFirst(AESIVWithTag.ivGenLength))
            newMode.iv = Array(cipherBytes.prefix(AESIVWithTag.ivGenLength))
        }
        
        let blockMode = newMode.blockMode(messageLength: cipherBytesWithoutIVPrefix.count, mode: .decrypt)
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        let decryptedBytes = try aes.decrypt(cipherBytesWithoutIVPrefix)
        
        if let plainText = String(bytes: decryptedBytes, encoding: .utf8) {
            return plainText
        } else {
            throw CryptoError.decodingFailed
        }
    }
}

private extension Int {
    static let ivGenLength: Int = 12
}
