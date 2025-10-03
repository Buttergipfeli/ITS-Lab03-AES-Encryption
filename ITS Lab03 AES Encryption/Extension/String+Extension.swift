import Foundation

extension String {
    func firstLetterUppercased() -> String {
        prefix(1).uppercased() + dropFirst()
    }
    
    var base64Encoded: String {
        Data(self.utf8).base64EncodedString()
    }
    
    func sanitizeToUTF8() -> String {
        self.unicodeScalars
            .filter { $0.isASCII && $0.value >= 32 && $0.value < 127 }
            .map { String($0) }
            .joined()
    }
    
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
