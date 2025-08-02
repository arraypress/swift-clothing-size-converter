/// Errors that can occur during size conversion
public enum ConversionError: Error, LocalizedError, Equatable, Sendable {
    case invalidSize(String)
    case unsupportedType(SizeType)
    case unsupportedSystem(SizeSystem, for: SizeType)
    case unsupportedConversion(from: SizeSystem, to: SizeSystem, type: SizeType)
    case ambiguousSize(String, suggestions: [String])
    case genderRequired(SizeType)
    case sizeOutOfRange(String, validRange: String)
    case invalidFormat(String, expectedFormat: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidSize(let size):
            return "Invalid size format: '\(size)'"
        case .unsupportedType(let type):
            return "Unsupported size type: \(type.rawValue)"
        case .unsupportedSystem(let system, let type):
            return "\(system.rawValue) sizing not supported for \(type.rawValue)"
        case .unsupportedConversion(let from, let to, let type):
            return "Cannot convert \(type.rawValue) from \(from.rawValue) to \(to.rawValue)"
        case .ambiguousSize(let size, let suggestions):
            return "Ambiguous size '\(size)'. Try: \(suggestions.joined(separator: ", "))"
        case .genderRequired(let type):
            return "Gender context required for \(type.rawValue) conversion"
        case .sizeOutOfRange(let size, let range):
            return "Size '\(size)' out of valid range: \(range)"
        case .invalidFormat(let size, let expectedFormat):
            return "Invalid format '\(size)'. Expected: \(expectedFormat)"
        }
    }
    
    /// User-friendly error message
    public var userFriendlyDescription: String {
        switch self {
        case .invalidSize(let size):
            return "'\(size)' is not a valid size"
        case .unsupportedType(let type):
            return "\(type.description) conversion not supported"
        case .unsupportedSystem(let system, let type):
            return "\(system.fullName) sizes not available for \(type.description.lowercased())"
        case .unsupportedConversion(let from, let to, let type):
            return "Can't convert \(type.description.lowercased()) from \(from.fullName) to \(to.fullName)"
        case .ambiguousSize(let size, let suggestions):
            return "Did you mean: \(suggestions.prefix(3).joined(separator: ", "))?"
        case .genderRequired(let type):
            return "Please specify gender for \(type.description.lowercased())"
        case .sizeOutOfRange(let size, let range):
            return "Size '\(size)' not found. Available: \(range)"
        case .invalidFormat(let size, let expectedFormat):
            return "Invalid format. Example: \(expectedFormat)"
        }
    }
}