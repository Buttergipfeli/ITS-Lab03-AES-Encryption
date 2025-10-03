import Foundation

protocol AESIVWithTagEncryptionServiceProtocol: AnyObject {
    func encrypt(text: String, mode: AESIVWithTag, key: String) throws -> String
    func decrypt(encryptedText: String, mode: AESIVWithTag, key: String) throws -> String
    func encrypt(bytes: [UInt8], mode: AESIVWithTag, key: String) throws -> [UInt8]
    func decrypt(cipherBytes: [UInt8], mode: AESIVWithTag, key: String) throws -> [UInt8]
}
