import Foundation

protocol AESIVWithTagEncryptionServiceProtocol: AnyObject {
    func encrypt(text: String, mode: AESIVWithTagMode, key: String) throws -> String
    func decrypt(encryptedText: String, mode: AESIVWithTagMode, key: String) throws -> String
}
