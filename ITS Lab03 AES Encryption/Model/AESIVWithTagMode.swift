import Foundation
import CryptoSwift

enum AESIVWithTagMode: String, CaseIterable, Identifiable {
    case gcm, ccm
    
    var id: Self { self }
}
