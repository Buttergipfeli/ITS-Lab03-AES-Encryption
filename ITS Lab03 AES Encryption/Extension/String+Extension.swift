import Foundation

extension String {
    func firstLetterUppercased() -> String {
        prefix(1).uppercased() + dropFirst()
    }
    
    func sanitizeToUTF8() -> String {
        self.unicodeScalars
            .filter { $0.isASCII && $0.value >= 32 && $0.value < 127 }
            .map { String($0) }
            .joined()
    }
}
