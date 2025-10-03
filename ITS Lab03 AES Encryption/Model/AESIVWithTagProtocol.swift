import CryptoSwift

protocol AESIVWithTagProtocol: BlockMode {
    var authenticationTag: [UInt8]? { get }
}
