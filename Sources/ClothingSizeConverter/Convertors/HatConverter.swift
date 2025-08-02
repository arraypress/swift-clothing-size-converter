//
//  HatConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


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