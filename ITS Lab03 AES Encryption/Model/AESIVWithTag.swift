import Foundation
import CryptoSwift

struct AESIVWithTag {
    let iv: String
    let mode: AESIVWithTagMode
    
    func blockMode(messageLength: Int, mode cryptoMode: CryptoMode) -> AESIVWithTagProtocol {
        switch mode {
        case .gcm:
            return GCM(iv: iv.bytes, tagLength: .tagLengthInBytes, mode: .combined)
        case .ccm:
            let actualMessageLength = messageLength - (cryptoMode == .encrypt ? .zero : .tagLengthInBytes)
            
            return CCM(iv: iv.bytes, tagLength: .tagLengthInBytes, messageLength: actualMessageLength)
        }
    }
}

private extension Int {
    static let tagLengthInBytes = 16
}

