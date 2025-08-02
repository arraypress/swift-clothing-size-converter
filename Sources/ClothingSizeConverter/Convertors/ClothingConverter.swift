//
//  ClothingConverter.swift
//  ClothingSizeConverter
//
//  Clothing size converter for shirts, dresses, and jackets with plus-size support
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

/// Converter for general clothing sizes including shirts, dresses, and jackets
///
/// Supports conversion between US, UK, EU, FR, IT, and AU sizing systems
/// for both men's and women's clothing. Includes extended plus-size ranges
/// and both letter sizes (XS-XXL) and numeric sizes.
///
/// ## Supported Systems
/// - **US**: Letter sizes (XS-XXXL) and numeric sizes (0-32 women's, 32-52 men's)
/// - **UK**: Similar to US with slight variations in numeric mapping
/// - **EU**: Numeric sizes (32-64 women's, 42-62 men's)
/// - **FR**: French sizing (32-60 women's, 38-56 men's)
/// - **IT**: Italian sizing (36-64 women's, 42-60 men's)
/// - **AU**: Australian sizing (similar to UK)
///
/// ## Size Types Supported
/// - Letter sizes: XS, S, M, L, XL, XXL, XXXL
/// - Plus sizes: 1X, 2X, 3X, 4X, 5X
/// - Women's numeric: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32
/// - Men's numeric: 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52
///
/// ## Example Usage
/// ```swift
/// let converter = ClothingConverter()
///
/// // Convert US women's size 8 to EU
/// let result = converter.convert(size: "8", from: .us, to: .eu, gender: .women)
/// // Result: "40"
///
/// // Convert men's letter size
/// let menResult = converter.convert(size: "L", from: .us, to: .eu, gender: .men)
/// // Result: "48"
///
/// // Plus size conversion
/// let plusResult = converter.convert(size: "2X", from: .us, to: .eu, gender: .men)
/// // Result: "54"
/// ```
internal struct ClothingConverter: SizeConverterProtocol {
    
    // MARK: - Protocol Properties
    
    /// Sizing systems supported by this converter
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .fr, .it, .au]
    }
    
    /// Whether gender context is required for accurate conversion
    var requiresGender: Bool {
        return true
    }
    
    // MARK: - Conversion Tables
    
    /// Men's clothing size conversion table
    ///
    /// Maps sizes from different systems to normalized US chest sizes.
    /// Includes letter sizes (XS-XXXL), plus sizes (1X-5X), and numeric sizes.
    /// All values represent equivalent US men's chest measurements for cross-reference.
    private let menClothingConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XS": 32, "S": 34, "M": 36, "L": 38, "XL": 40, "XXL": 42, "XXXL": 44,
            // Plus sizes
            "1X": 42, "2X": 44, "3X": 46, "4X": 48, "5X": 50,
            // Numeric sizes
            "32": 32, "34": 34, "36": 36, "38": 38, "40": 40, "42": 42, "44": 44, "46": 46, "48": 48, "50": 50, "52": 52
        ],
        .uk: [
            "XS": 32, "S": 34, "M": 36, "L": 38, "XL": 40, "XXL": 42, "XXXL": 44,
            "32": 32, "34": 34, "36": 36, "38": 38, "40": 40, "42": 42, "44": 44, "46": 46
        ],
        .eu: [
            "42": 32, "44": 34, "46": 36, "48": 38, "50": 40, "52": 42, "54": 44, "56": 46, "58": 48, "60": 50, "62": 52
        ],
        .fr: [
            "38": 32, "40": 34, "42": 36, "44": 38, "46": 40, "48": 42, "50": 44, "52": 46, "54": 48, "56": 50
        ],
        .it: [
            "42": 32, "44": 34, "46": 36, "48": 38, "50": 40, "52": 42, "54": 44, "56": 46, "58": 48, "60": 50
        ],
        .au: [
            "XS": 32, "S": 34, "M": 36, "L": 38, "XL": 40, "XXL": 42,
            "32": 32, "34": 34, "36": 36, "38": 38, "40": 40, "42": 42, "44": 44, "46": 46
        ]
    ]
    
    /// Women's clothing size conversion table
    ///
    /// Maps sizes from different systems to normalized US dress sizes.
    /// Includes letter sizes (XXS-XXL), plus sizes (1X-5X), and numeric sizes (0-32).
    /// European and Italian systems use different numeric progressions.
    private let womenClothingConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XXS": 0, "XS": 2, "S": 4, "M": 8, "L": 12, "XL": 16, "XXL": 20,
            // Plus sizes
            "1X": 22, "2X": 24, "3X": 26, "4X": 28, "5X": 30,
            // Numeric sizes (regular and plus)
            "0": 0, "2": 2, "4": 4, "6": 6, "8": 8, "10": 10, "12": 12, "14": 14, "16": 16, "18": 18, "20": 20,
            "22": 22, "24": 24, "26": 26, "28": 28, "30": 30, "32": 32
        ],
        .uk: [
            "XXS": 0, "XS": 2, "S": 4, "M": 8, "L": 12, "XL": 16, "XXL": 20,
            "4": 0, "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18, "24": 20,
            "26": 22, "28": 24, "30": 26, "32": 28
        ],
        .eu: [
            "32": 0, "34": 2, "36": 4, "38": 6, "40": 8, "42": 10, "44": 12, "46": 14, "48": 16, "50": 18, "52": 20,
            "54": 22, "56": 24, "58": 26, "60": 28, "62": 30, "64": 32
        ],
        .fr: [
            "32": 0, "34": 2, "36": 4, "38": 6, "40": 8, "42": 10, "44": 12, "46": 14, "48": 16, "50": 18, "52": 20,
            "54": 22, "56": 24, "58": 26, "60": 28
        ],
        .it: [
            "36": 0, "38": 2, "40": 4, "42": 6, "44": 8, "46": 10, "48": 12, "50": 14, "52": 16, "54": 18, "56": 20,
            "58": 22, "60": 24, "62": 26, "64": 28
        ],
        .au: [
            "XXS": 0, "XS": 2, "S": 4, "M": 8, "L": 12, "XL": 16, "XXL": 20,
            "4": 0, "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18, "24": 20
        ]
    ]
    
    // MARK: - Public Methods
    
    /// Convert a clothing size between systems
    ///
    /// Performs a simple conversion without detailed metadata.
    /// Supports both letter sizes (M, L, XL) and numeric sizes.
    ///
    /// - Parameters:
    ///   - size: Source clothing size (e.g., "M", "8", "42", "1X")
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context (.men or .women required)
    /// - Returns: Converted size string, or nil if conversion fails
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .clothing).convertedSize
    }
    
    /// Convert clothing size with detailed conversion information
    ///
    /// Provides comprehensive conversion results including confidence scores,
    /// notes about sizing variations, and fallback conversion formulas.
    ///
    /// ## Conversion Process
    /// 1. Normalize input size (handle spacing, case)
    /// 2. Validate source and target systems are supported
    /// 3. Handle same-system conversions with validation
    /// 4. Convert via normalized US size reference
    /// 5. Apply fallback formulas for EU conversions (US + 10 men's, US + 30 women's)
    /// 6. Generate confidence scores and helpful notes
    ///
    /// ## Fallback Conversions
    /// When exact table matches aren't found, standard formulas are applied:
    /// - **Men's US to EU**: Add 10 (US 38 → EU 48)
    /// - **Women's US to EU**: Add 30 (US 8 → EU 38)
    ///
    /// - Parameters:
    ///   - size: Source clothing size to convert
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context for sizing differences
    ///   - type: Size type (clothing, dress, or jacket)
    /// - Returns: Detailed conversion result with metadata
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalizedSize = size.normalizedSize
        
        guard supportedSystems.contains(from) && supportedSystems.contains(to) else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .unsupportedSystem(from, for: type)
            )
        }
        
        if from == to {
            if isValid(size: normalizedSize, system: from, gender: gender) {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: normalizedSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 1.0
                )
            } else {
                return ConversionResult(
                    originalSize: size,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    error: .invalidSize(size)
                )
            }
        }
        
        let conversions = gender == .women ? womenClothingConversions : menClothingConversions
        
        guard let fromTable = conversions[from],
              let usSize = fromTable[normalizedSize] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        guard let toTable = conversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .unsupportedSystem(to, for: type)
            )
        }
        
        // Find the target size by matching the normalized US size
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 0.9
                )
            }
        }
        
        // If exact match not found in table, try standard conversion formulas
        if to == .eu && gender == .men {
            // US to EU men's clothing: add 10 to the US size
            let euNumericSize = Int(usSize) + 10
            return ConversionResult(
                originalSize: size,
                convertedSize: String(euNumericSize),
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                confidence: 0.85,
                notes: "Converted using standard US to EU sizing (+10)"
            )
        }
        
        if to == .eu && gender == .women {
            // US to EU women's clothing: add 30 to the US size
            let euNumericSize = Int(usSize) + 30
            return ConversionResult(
                originalSize: size,
                convertedSize: String(euNumericSize),
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                confidence: 0.85,
                notes: "Converted using standard US to EU sizing (+30)"
            )
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "Standard sizes")
        )
    }
    
    /// Validate if a clothing size is valid for the given system and gender
    ///
    /// Checks if the size exists in the appropriate conversion table.
    /// Handles both letter sizes and numeric sizes.
    ///
    /// ## Valid Formats
    /// - **Letter sizes**: XS, S, M, L, XL, XXL, XXXL
    /// - **Plus sizes**: 1X, 2X, 3X, 4X, 5X
    /// - **Women's numeric**: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32
    /// - **Men's numeric**: 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52
    ///
    /// - Parameters:
    ///   - size: Size string to validate
    ///   - system: Sizing system to check against
    ///   - gender: Gender context for validation
    /// - Returns: True if size is valid and convertible
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalized = size.normalizedSize
        let conversions = gender == .women ? womenClothingConversions : menClothingConversions
        return conversions[system]?.keys.contains(normalized) == true
    }
    
    /// Get suggestions for invalid or ambiguous clothing sizes
    ///
    /// Provides helpful alternatives when a size cannot be validated.
    /// Returns common letter sizes as safe fallbacks.
    ///
    /// - Parameters:
    ///   - size: Invalid size string
    ///   - system: Target sizing system
    ///   - gender: Gender context for suggestions
    /// - Returns: Array of suggested valid sizes
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        // Return common sizes as suggestions
        if gender == .women {
            return ["XS", "S", "M", "L", "XL", "6", "8", "10", "12", "14"]
        } else {
            return ["S", "M", "L", "XL", "34", "36", "38", "40", "42"]
        }
    }
    
}
