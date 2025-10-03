import Foundation
import CryptoSwift
import Security

// DOC: https://cryptoswift.io/#aes-gcm
final class AESIVWithTagEncryptionService: AESIVWithTagEncryptionServiceProtocol {
    func encrypt(text: String, mode: AESIVWithTag, key: String) throws -> String {
        let encryptedBytesWithIVPrefix = try encrypt(bytes: text.bytes, mode: mode, key: key)
        
        return Data(encryptedBytesWithIVPrefix).base64EncodedString()
    }
    
    func decrypt(encryptedText: String, mode: AESIVWithTag, key: String) throws -> String {
        guard let cipherData = Data(base64Encoded: encryptedText) else { throw CryptoError.decodingFailed }
        let decryptedBytes = try decrypt(cipherBytes: Array(cipherData), mode: mode, key: key)
        
        if let plainText = String(bytes: decryptedBytes, encoding: .utf8) {
            return plainText
        } else {
            throw CryptoError.decodingFailed
        }
    }
    
    func encrypt(bytes: [UInt8], mode: AESIVWithTag, key: String) throws -> [UInt8] {
        let blockMode = mode.blockMode(messageLength: bytes.count, mode: .encrypt)
        let aes = try AES(key: key.bytes, blockMode: blockMode, padding: .noPadding)
        
        let encryptedBytes = try aes.encrypt(bytes)
        return (mode.usedCustomIV ? [] : mode.iv) + encryptedBytes
    }
    
    func decrypt(cipherBytes: [UInt8], mode: AESIVWithTag, key: String) throws -> [UInt8] {
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
        
        return try aes.decrypt(cipherBytesWithoutIVPrefix)
    }
}

private extension Int {
    static let ivGenLength: Int = 12
}
