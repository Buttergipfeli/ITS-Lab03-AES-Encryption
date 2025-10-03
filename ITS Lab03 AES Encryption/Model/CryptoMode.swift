enum CryptoMode: String, CaseIterable, Identifiable {
    case encrypt, decrypt
    
    var id: Self { self }
}
