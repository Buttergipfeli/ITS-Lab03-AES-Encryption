import Foundation

protocol AESIVWithTagEncryptionServiceProtocol: AnyObject {
    func encrypt(text: String, mode: AESIVWithTag, key: String) throws -> String
    func decrypt(encryptedText: String, mode: AESIVWithTag, key: String) throws -> String
}
