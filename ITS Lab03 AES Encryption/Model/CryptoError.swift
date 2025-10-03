import CommonCrypto

public enum CryptoError: Error {
    case invalidBase64, nonUTF8, badKeyLength, badIVLength, ccmUnavailable
    case ccError(CCCryptorStatus)
}
