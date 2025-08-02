//
//  RemainingConverters.swift
//  ClothingSizeConverter
//
//  Ring, Hat, Glove, Belt, Sock, Watch, Children's, and Swimwear converters
//  Created on 28/07/2025.
//

import Foundation

// MARK: - Ring Converter

/// Converter for ring sizes across international systems
///
/// Supports conversion between US, UK, EU, JP, inches, and centimeter sizing systems.
/// Ring sizing is based on the internal circumference or diameter of the ring.
///
/// ## Supported Systems
/// - **US**: Numeric sizes 3-12 (standard US ring sizing)
/// - **UK**: Letter sizes F-X (British alphabetical system)
/// - **EU**: Numeric sizes 44-62 (European millimeter circumference)
/// - **JP**: Numeric sizes 3-25 (Japanese sizing system)
/// - **Inches**: Decimal measurements 1.833-2.118 (internal diameter)
/// - **CM**: Decimal measurements 4.65-5.37 (internal circumference)
///
/// ## Example Usage
/// ```swift
/// let converter = RingConverter()
///
/// // Convert US size 7 to UK
/// let result = converter.convert(size: "7", from: .us, to: .uk, gender: .unisex)
/// // Result: "N"
///
/// // Convert to metric measurements
/// let cmResult = converter.convert(size: "7", from: .us, to: .cm, gender: .unisex)
/// // Result: "4.98"
/// ```
internal struct RingConverter: SizeConverterProtocol {
    
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .jp, .inches, .cm]
    }
    
    var requiresGender: Bool {
        return false
    }
    
    /// Ring size conversion table mapping all systems to normalized US sizes
    private let conversions: [SizeSystem: [String: Double]] = [
        .us: ["3": 3, "3.5": 3.5, "4": 4, "4.5": 4.5, "5": 5, "5.5": 5.5, "6": 6, "6.5": 6.5, "7": 7, "7.5": 7.5, "8": 8, "8.5": 8.5, "9": 9, "9.5": 9.5, "10": 10, "10.5": 10.5, "11": 11, "11.5": 11.5, "12": 12],
        .uk: ["F": 3, "G": 3.5, "H": 4, "I": 4.5, "J": 5, "K": 5.5, "L": 6, "M": 6.5, "N": 7, "O": 7.5, "P": 8, "Q": 8.5, "R": 9, "S": 9.5, "T": 10, "U": 10.5, "V": 11, "W": 11.5, "X": 12],
        .eu: ["44": 3, "45": 3.5, "46": 4, "47": 4.5, "48": 5, "49": 5.5, "50": 6, "51": 6.5, "52": 7, "53": 7.5, "54": 8, "55": 8.5, "56": 9, "57": 9.5, "58": 10, "59": 10.5, "60": 11, "61": 11.5, "62": 12],
        .jp: ["3": 3, "5": 3.5, "7": 4, "8": 4.5, "9": 5, "11": 5.5, "13": 6, "14": 6.5, "15": 7, "16": 7.5, "17": 8, "18": 8.5, "19": 9, "20": 9.5, "21": 10, "22": 10.5, "23": 11, "24": 11.5, "25": 12],
        .inches: ["1.833": 3, "1.849": 3.5, "1.865": 4, "1.881": 4.5, "1.896": 5, "1.912": 5.5, "1.928": 6, "1.944": 6.5, "1.960": 7, "1.976": 7.5, "1.991": 8, "2.007": 8.5, "2.023": 9, "2.039": 9.5, "2.055": 10, "2.071": 10.5, "2.086": 11, "2.102": 11.5, "2.118": 12],
        .cm: ["4.65": 3, "4.70": 3.5, "4.74": 4, "4.78": 4.5, "4.82": 5, "4.86": 5.5, "4.90": 6, "4.94": 6.5, "4.98": 7, "5.02": 7.5, "5.05": 8, "5.09": 8.5, "5.13": 9, "5.17": 9.5, "5.21": 10, "5.25": 10.5, "5.29": 11, "5.33": 11.5, "5.37": 12]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .ring).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        guard let fromTable = conversions[from],
              let toTable = conversions[to],
              let usSize = fromTable[size.normalizedSize] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 0.98,
                    notes: "Ring sizing is based on internal circumference"
                )
            }
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "3-12")
        )
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        return conversions[system]?.keys.contains(size.normalizedSize) == true
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["6", "6.5", "7", "7.5", "8"]
    }
}

// MARK: - Hat Converter

/// Converter for hat sizes with fractional support
///
/// Supports conversion between US, UK, EU, CM, and inches sizing systems.
/// Hat sizing is based on head circumference measurements.
///
/// ## Supported Systems
/// - **US/UK**: Fractional sizes 6.5-8 (6 1/8, 6 1/4, 7, 7 1/8, etc.)
/// - **EU/CM**: Centimeter measurements 52-64
/// - **Inches**: Inch measurements 20.5-25
///
/// ## Fractional Handling
/// Supports common hat size fractions:
/// - 1/8 = .125, 1/4 = .25, 3/8 = .375, 1/2 = .5, 5/8 = .625, 3/4 = .75, 7/8 = .875
///
/// ## Example Usage
/// ```swift
/// let converter = HatConverter()
///
/// // Convert US 7 to EU
/// let result = converter.convert(size: "7", from: .us, to: .eu, gender: .unisex)
/// // Result: "56"
///
/// // Handle fractional sizes
/// let fractional = converter.convert(size: "7 1/8", from: .us, to: .eu, gender: .unisex)
/// // Result: "57"
/// ```
internal struct HatConverter: SizeConverterProtocol {
    
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .cm, .inches]
    }
    
    var requiresGender: Bool {
        return false
    }
    
    /// Hat size conversion table with fractional decimal equivalents
    private let conversions: [SizeSystem: [String: Double]] = [
        .us: ["6.5": 6.5, "6.625": 6.625, "6.75": 6.75, "6.875": 6.875, "7": 7, "7.125": 7.125, "7.25": 7.25, "7.375": 7.375, "7.5": 7.5, "7.625": 7.625, "7.75": 7.75, "7.875": 7.875, "8": 8],
        .uk: ["6.5": 6.5, "6.625": 6.625, "6.75": 6.75, "6.875": 6.875, "7": 7, "7.125": 7.125, "7.25": 7.25, "7.375": 7.375, "7.5": 7.5, "7.625": 7.625, "7.75": 7.75, "7.875": 7.875, "8": 8],
        .eu: ["52": 6.5, "53": 6.625, "54": 6.75, "55": 6.875, "56": 7, "57": 7.125, "58": 7.25, "59": 7.375, "60": 7.5, "61": 7.625, "62": 7.75, "63": 7.875, "64": 8],
        .cm: ["52": 6.5, "53": 6.625, "54": 6.75, "55": 6.875, "56": 7, "57": 7.125, "58": 7.25, "59": 7.375, "60": 7.5, "61": 7.625, "62": 7.75, "63": 7.875, "64": 8],
        .inches: ["20.5": 6.5, "20.875": 6.625, "21.25": 6.75, "21.625": 6.875, "22": 7, "22.375": 7.125, "22.75": 7.25, "23.125": 7.375, "23.5": 7.5, "23.875": 7.625, "24.25": 7.75, "24.625": 7.875, "25": 8]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .hat).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = normalizeFractionalSize(size.normalizedSize)
        
        guard let fromTable = conversions[from],
              let toTable = conversions[to],
              let usSize = fromTable[normalized] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 0.95,
                    notes: "Hat sizing based on head circumference"
                )
            }
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "6.5-8")
        )
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalized = normalizeFractionalSize(size.normalizedSize)
        return conversions[system]?.keys.contains(normalized) == true
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        if size.contains("/") {
            return [normalizeFractionalSize(size)]
        }
        return ["7", "7.125", "7.25", "7.5"]
    }
    
    /// Convert fractional hat sizes to decimal equivalents
    ///
    /// Handles common hat size fractions like "7 1/8" → "7.125"
    private func normalizeFractionalSize(_ size: String) -> String {
        if size.contains("1/8") {
            return size.replacingOccurrences(of: " 1/8", with: ".125")
        } else if size.contains("1/4") {
            return size.replacingOccurrences(of: " 1/4", with: ".25")
        } else if size.contains("3/8") {
            return size.replacingOccurrences(of: " 3/8", with: ".375")
        } else if size.contains("5/8") {
            return size.replacingOccurrences(of: " 5/8", with: ".625")
        } else if size.contains("3/4") {
            return size.replacingOccurrences(of: " 3/4", with: ".75")
        } else if size.contains("7/8") {
            return size.replacingOccurrences(of: " 7/8", with: ".875")
        }
        return size
    }
}

// MARK: - Simple Converters

/// Converter for glove sizes with letter and numeric support
///
/// Supports XS-XL letter sizes and numeric sizes 6-10.
/// Most systems use universal letter sizing.
internal struct GloveConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu] }
    var requiresGender: Bool { false }
    
    private let conversions: [SizeSystem: [String: String]] = [
        .us: ["XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL", "6": "XS", "7": "S", "8": "M", "9": "L", "10": "XL"],
        .uk: ["XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL"],
        .eu: ["6": "XS", "7": "S", "8": "M", "9": "L", "10": "XL", "XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL"]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        guard let fromTable = conversions[from], let targetSize = fromTable[size.normalizedSize] else { return nil }
        return conversions[to]?[targetSize]
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 0.9)
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        return conversions[system]?.keys.contains(size.normalizedSize) == true
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["XS", "S", "M", "L", "XL"]
    }
}

/// Converter for belt/waist sizes with metric support
///
/// Supports US/UK inch measurements, EU centimeter measurements,
/// and direct centimeter/inch conversions.
internal struct BeltConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .cm, .inches] }
    var requiresGender: Bool { false }
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        guard let waistSize = Int(size.normalizedSize) else { return nil }
        
        switch (from, to) {
        case (.us, .eu), (.uk, .eu): return String(waistSize + 16)
        case (.eu, .us), (.eu, .uk): return String(waistSize - 16)
        case (.us, .cm), (.uk, .cm): return String(Int(Double(waistSize) * 2.54))
        case (.cm, .us), (.cm, .uk): return String(Int(Double(waistSize) / 2.54))
        default: return size.normalizedSize
        }
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 0.9)
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        return Int(size.normalizedSize) != nil && Int(size.normalizedSize)! >= 28 && Int(size.normalizedSize)! <= 50
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["30", "32", "34", "36", "38", "40"]
    }
}

/// Converter for sock sizes using shoe size logic
///
/// Socks typically follow the same sizing as shoes since they're based on foot size.
internal struct SockConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu] }
    var requiresGender: Bool { false }
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        let shoeConverter = ShoeConverter()
        return shoeConverter.convert(size: size, from: from, to: to, gender: gender)
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let shoeConverter = ShoeConverter()
        return shoeConverter.convertWithDetails(size: size, from: from, to: to, gender: gender, type: type)
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let shoeConverter = ShoeConverter()
        return shoeConverter.isValid(size: size, system: system, gender: gender)
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["6", "7", "8", "9", "10", "11", "12"]
    }
}

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

// MARK: - Children's Converter

/// Converter for children's clothing sizes across age groups
///
/// Supports infant (0-24M), toddler (2T-5T), children's (4-20), and youth (XS-XL) sizing.
/// Each age group uses different sizing conventions based on age and height.
internal struct ChildrenConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .fr] }
    var requiresGender: Bool { true }
    
    // Age-based conversion tables for different children's categories
    private let infantConversions: [SizeSystem: [String: Double]] = [
        .us: ["0M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24],
        .uk: ["0M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24],
        .eu: ["50": 0, "56": 3, "62": 6, "68": 9, "74": 12, "80": 18, "86": 24],
        .fr: ["1M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24]
    ]
    
    private let toddlerConversions: [SizeSystem: [String: Double]] = [
        .us: ["2T": 2, "3T": 3, "4T": 4, "5T": 5],
        .uk: ["2": 2, "3": 3, "4": 4, "5": 5],
        .eu: ["92": 2, "98": 3, "104": 4, "110": 5],
        .fr: ["2A": 2, "3A": 3, "4A": 4, "5A": 5]
    ]
    
    private let childrenConversions: [SizeSystem: [String: Double]] = [
        .us: ["4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "10": 10, "12": 12, "14": 14, "16": 16, "18": 18, "20": 20],
        .uk: ["4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "10": 10, "12": 12, "14": 14, "16": 16, "18": 18, "20": 20],
        .eu: ["104": 4, "110": 5, "116": 6, "122": 7, "128": 8, "140": 10, "152": 12, "164": 14, "170": 16, "176": 18, "182": 20],
        .fr: ["4A": 4, "5A": 5, "6A": 6, "7A": 7, "8A": 8, "10A": 10, "12A": 12, "14A": 14, "16A": 16, "18A": 18, "20A": 20]
    ]
    
    private let youthConversions: [SizeSystem: [String: Double]] = [
        .us: ["XS": 6, "S": 8, "M": 10, "L": 12, "XL": 14],
        .uk: ["XS": 6, "S": 8, "M": 10, "L": 12, "XL": 14],
        .eu: ["116": 6, "128": 8, "140": 10, "152": 12, "164": 14],
        .fr: ["6A": 6, "8A": 8, "10A": 10, "12A": 12, "14A": 14]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .clothing).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = size.normalizedSize
        
        let conversions: [SizeSystem: [String: Double]]
        
        if normalized.matches(SizePatterns.infantSize) {
            conversions = infantConversions
        } else if normalized.matches(SizePatterns.toddlerSize) {
            conversions = toddlerConversions
        } else if normalized.matches(SizePatterns.youthSize) {
            conversions = youthConversions
        } else if normalized.matches(SizePatterns.childrenSize) {
            conversions = childrenConversions
        } else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidFormat(size, expectedFormat: "3M, 2T, 4, XS")
            )
        }
        
        guard let fromTable = conversions[from],
              let usSize = fromTable[normalized],
              let toTable = conversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 0.9,
                    notes: "Children's sizing based on age/height"
                )
            }
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "Age-appropriate sizes")
        )
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalized = size.normalizedSize
        let allTables = [infantConversions, toddlerConversions, childrenConversions, youthConversions]
        
        for table in allTables {
            if table[system]?.keys.contains(normalized) == true {
                return true
            }
        }
        return false
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        if size.contains("M") {
            return ["3M", "6M", "12M", "18M", "24M"]
        } else if size.contains("T") {
            return ["2T", "3T", "4T", "5T"]
        } else if size.matches(SizePatterns.youthSize) {
            return ["XS", "S", "M", "L", "XL"]
        } else {
            return ["4", "6", "8", "10", "12", "14"]
        }
    }
}

// MARK: - Swimwear Converter

/// Converter for swimwear sizes with gender-specific differences
///
/// Swimwear sizing differs from regular clothing, especially for women's pieces
/// which may include cup sizing like bras or use different letter size mappings.
internal struct SwimwearConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .au] }
    var requiresGender: Bool { true }
    
    private let womenSwimwearConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XS": 2, "S": 4, "M": 6, "L": 10, "XL": 14, "XXL": 18,
            "32A": 2, "32B": 2, "34A": 4, "34B": 4, "34C": 6, "36B": 6, "36C": 8, "38B": 10, "38C": 12, "40B": 14, "40C": 16
        ],
        .uk: [
            "XS": 2, "S": 4, "M": 6, "L": 10, "XL": 14, "XXL": 18,
            "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18
        ],
        .eu: [
            "XS": 2, "S": 4, "M": 6, "L": 10, "XL": 14, "XXL": 18,
            "32": 2, "34": 4, "36": 6, "38": 8, "40": 10, "42": 12, "44": 14, "46": 16, "48": 18
        ],
        .au: [
            "XS": 2, "S": 4, "M": 6, "L": 10, "XL": 14, "XXL": 18,
            "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18
        ]
    ]
    
    private let menSwimwearConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XS": 28, "S": 30, "M": 32, "L": 34, "XL": 36, "XXL": 38,
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38, "40": 40
        ],
        .uk: [
            "XS": 28, "S": 30, "M": 32, "L": 34, "XL": 36, "XXL": 38,
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38
        ],
        .eu: [
            "XS": 28, "S": 30, "M": 32, "L": 34, "XL": 36, "XXL": 38,
            "44": 28, "46": 30, "48": 32, "50": 34, "52": 36, "54": 38
        ],
        .au: [
            "XS": 28, "S": 30, "M": 32, "L": 34, "XL": 36, "XXL": 38,
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38
        ]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .swimwear).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = size.normalizedSize
        let conversions = gender == .women ? womenSwimwearConversions : menSwimwearConversions
        
        guard let fromTable = conversions[from],
              let usSize = fromTable[normalized],
              let toTable = conversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 0.85,
                    notes: "Swimwear sizing varies by brand and style"
                )
            }
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "XS-XXL or cup sizes")
        )
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let conversions = gender == .women ? womenSwimwearConversions : menSwimwearConversions
        return conversions[system]?.keys.contains(size.normalizedSize) == true
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        if gender == .women {
            return ["XS", "S", "M", "L", "XL", "32B", "34B", "36C"]
        } else {
            return ["S", "M", "L", "XL", "30", "32", "34", "36"]
        }
    }
}
