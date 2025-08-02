/// Converter for watch case sizes
///
/// Watch sizes are typically universal (38mm, 42mm, etc.) based on case diameter.
/// Supports mm suffix handling.
internal struct WatchConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .eu, .cm] }
    var requiresGender: Bool { false }
    
    private let conversions: [SizeSystem: [String: String]] = [
        .us: ["38": "38", "40": "40", "42": "42", "44": "44", "46": "46"],
        .eu: ["38": "38", "40": "40", "42": "42", "44": "44", "46": "46"],
        .cm: ["3.8": "38", "4.0": "40", "4.2": "42", "4.4": "44", "4.6": "46"]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        let normalized = size.normalizedSize.replacingOccurrences(of: "MM", with: "").replacingOccurrences(of: "mm", with: "")
        
        if let _ = Int(normalized) {
            return normalized
        }
        
        return conversions[to]?[normalized] ?? normalized
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 1.0)
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalized = size.normalizedSize.replacingOccurrences(of: "MM", with: "").replacingOccurrences(of: "mm", with: "")
        return conversions[system]?.keys.contains(normalized) == true || Int(normalized) != nil
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["38", "40", "42", "44", "46"]
    }
}