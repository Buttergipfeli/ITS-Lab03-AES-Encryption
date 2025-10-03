import Foundation
import CryptoSwift

struct AESIVWithTag {
    static let ivGenLength: Int = 12
    
    var iv: [UInt8]
    let mode: AESIVWithTagMode
    let usedCustomIV: Bool
    
    init(iv: String?, mode: AESIVWithTagMode) {
        self.iv = iv?.bytes ?? AES.randomIV(Self.ivGenLength)
        self.mode = mode
        usedCustomIV = iv != nil
    }
    
    func blockMode(messageLength: Int, mode cryptoMode: CryptoMode) -> AESIVWithTagProtocol {
        switch mode {
        case .gcm:
            return GCM(iv: iv, tagLength: .tagLengthInBytes, mode: .combined)
        case .ccm:
            let actualMessageLength = messageLength - (cryptoMode == .encrypt ? .zero : .tagLengthInBytes)
            
            return CCM(iv: iv, tagLength: .tagLengthInBytes, messageLength: actualMessageLength)
        }
    }
}

private extension Int {
    static let tagLengthInBytes = 16
}

