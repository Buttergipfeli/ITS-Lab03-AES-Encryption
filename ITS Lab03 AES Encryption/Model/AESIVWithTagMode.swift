import Foundation
import CryptoSwift

public enum AESIVWithTagMode {
    case gcm(iv: [UInt8])
    case ccm(iv: [UInt8])
    
    func blockMode(messageLength: Int, encrypt: Bool) -> AESIVWithTagProtocol {
        switch self {
        case .gcm(let iv):
            return GCM(iv: iv, tagLength: .tagLengthInBytes, mode: .combined)
        case .ccm(let iv):
            let actualMessageLength = messageLength - (encrypt ? .zero : .tagLengthInBytes)
            
            return CCM(iv: iv, tagLength: .tagLengthInBytes, messageLength: actualMessageLength)
        }
    }
}

private extension Int {
    static let tagLengthInBytes = 16
}
