//
//  BraConverter.swift
//  ClothingSizeConverter
//
//  Bra size converter with comprehensive international support and cup sizing
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

/// Converter for bra sizes across international systems
///
/// Supports conversion between US, UK, EU, FR, and AU bra sizing systems.
/// Handles both band sizes (numeric part) and cup sizes (letter part) separately
/// for accurate conversion across different regional sizing standards.
///
/// ## Supported Systems
/// - **US**: Band 30-44, Cups A-G (30A, 34B, 36DD, etc.)
/// - **UK**: Band 30-44, Cups A-FF (34B, 36E instead of DDD)
/// - **EU**: Band 65-100, Cups A-H (75B = 34B US)
/// - **FR**: Band 80-115, Cups A-H (90B = 34B US)
/// - **AU**: Band 8-22, Cups A-G (Australian numeric bands)
///
/// ## Size Format
/// Bra sizes consist of two components:
/// - **Band size**: Numeric measurement around ribcage
/// - **Cup size**: Letter(s) indicating breast volume
///
/// Examples: "34B", "36DD", "32DDD", "38G"
///
/// ## Regional Differences
/// - **US**: Uses DD, DDD progression
/// - **UK**: Uses DD, E, F, FF progression (E = US DDD)
/// - **EU/FR**: Uses single letters with E = US DD
/// - **AU**: Similar to US system
///
/// ## Example Usage
/// ```swift
/// let converter = BraConverter()
///
/// // Convert US 34B to EU
/// let result = converter.convert(size: "34B", from: .us, to: .eu, gender: .women)
/// // Result: "75B"
///
/// // Convert with cup size differences
/// let ukResult = converter.convert(size: "34DDD", from: .us, to: .uk, gender: .women)
/// // Result: "34E" (UK uses E instead of DDD)
///
/// // Australian sizing
/// let auResult = converter.convert(size: "34B", from: .us, to: .au, gender: .women)
/// // Result: "12B" (AU uses different band numbering)
/// ```
internal struct BraConverter: SizeConverterProtocol {
    
    // MARK: - Protocol Properties
    
    /// Sizing systems supported by this converter
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .fr, .au]
    }
    
    /// Whether gender context is required (false - bras are women-specific)
    var requiresGender: Bool {
        return false
    }
    
    // MARK: - Conversion Tables
    
    /// Band size conversions (numeric component)
    ///
    /// Maps band measurements from different systems to normalized US band sizes.
    /// Each system uses different numbering but represents the same physical measurement.
    ///
    /// **Conversion Logic:**
    /// - US/UK: Direct inch measurements (30", 32", 34", etc.)
    /// - EU: Centimeter measurements (65cm = 30", 70cm = 32", etc.)
    /// - FR: Centimeter + 15 offset (80cm = 30", 85cm = 32", etc.)
    /// - AU: Dress size equivalent (8 = 30", 10 = 32", etc.)
    private let bandConversions: [SizeSystem: [String: Int]] = [
        .us: ["30": 30, "32": 32, "34": 34, "36": 36, "38": 38, "40": 40, "42": 42, "44": 44],
        .uk: ["30": 30, "32": 32, "34": 34, "36": 36, "38": 38, "40": 40, "42": 42, "44": 44],
        .eu: ["65": 30, "70": 32, "75": 34, "80": 36, "85": 38, "90": 40, "95": 42, "100": 44],
        .fr: ["80": 30, "85": 32, "90": 34, "95": 36, "100": 38, "105": 40, "110": 42, "115": 44],
        .au: ["8": 30, "10": 32, "12": 34, "14": 36, "16": 38, "18": 40, "20": 42, "22": 44]
    ]
    
    /// Cup size conversions (letter component)
    ///
    /// Maps cup designations from different systems to normalized US cup sizes.
    /// Regional differences in cup progression require careful mapping.
    ///
    /// **Key Differences:**
    /// - US: A, B, C, D, DD, DDD, F, G
    /// - UK: A, B, C, D, DD, E, F, FF (E replaces DDD, FF replaces G)
    /// - EU/FR: A, B, C, D, E, F, G, H (E = US DD, F = US DDD)
    /// - AU: Similar to US system
    private let cupConversions: [SizeSystem: [String: String]] = [
        .us: ["A": "A", "B": "B", "C": "C", "D": "D", "DD": "DD", "DDD": "DDD", "F": "F", "G": "G"],
        .uk: ["A": "A", "B": "B", "C": "C", "D": "D", "DD": "DD", "E": "DDD", "F": "F", "FF": "G"],
        .eu: ["A": "A", "B": "B", "C": "C", "D": "D", "E": "DD", "F": "DDD", "G": "F", "H": "G"],
        .fr: ["A": "A", "B": "B", "C": "C", "D": "D", "E": "DD", "F": "DDD", "G": "F", "H": "G"],
        .au: ["A": "A", "B": "B", "C": "C", "D": "D", "DD": "DD", "E": "DDD", "F": "F", "G": "G"]
    ]
    
    // MARK: - Public Methods
    
    /// Convert a bra size between systems
    ///
    /// Performs a simple conversion without detailed metadata.
    /// Handles both band and cup size conversion simultaneously.
    ///
    /// - Parameters:
    ///   - size: Source bra size in format "34B", "36DD", etc.
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context (ignored - bras are women-specific)
    /// - Returns: Converted bra size string, or nil if conversion fails
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .bra).convertedSize
    }
    
    /// Convert bra size with detailed conversion information
    ///
    /// Provides comprehensive conversion results including confidence scores
    /// and notes about regional cup size differences.
    ///
    /// ## Conversion Process
    /// 1. Parse input size into band and cup components using regex
    /// 2. Validate both components exist in source system tables
    /// 3. Convert band size via normalized US equivalent
    /// 4. Convert cup size via normalized US equivalent
    /// 5. Combine converted band and cup into target size format
    /// 6. Apply confidence scoring (high for bra conversions)
    ///
    /// ## Error Handling
    /// - Invalid format: Not in "##Letter" format (e.g., "34B")
    /// - Unsupported band: Band size not in conversion table
    /// - Unsupported cup: Cup size not in conversion table
    /// - System limitations: Target system doesn't support size
    ///
    /// - Parameters:
    ///   - size: Source bra size to convert
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context (forced to .women)
    ///   - type: Size type (should be .bra for this converter)
    /// - Returns: Detailed conversion result with metadata
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = size.normalizedSize
        
        // Parse band and cup from size like "34B"
        guard let (band, cup) = parseBraSize(normalized) else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: .women,
                error: .invalidFormat(size, expectedFormat: "34B")
            )
        }
        
        guard let fromBandTable = bandConversions[from],
              let fromCupTable = cupConversions[from],
              let toBandTable = bandConversions[to],
              let toCupTable = cupConversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: .women,
                error: .unsupportedSystem(from, for: type)
            )
        }
        
        guard let normalizedBand = fromBandTable[band],
              let normalizedCup = fromCupTable[cup] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: .women,
                error: .invalidSize(size)
            )
        }
        
        // Find equivalent in target system
        var targetBand: String?
        var targetCup: String?
        
        for (toBand, toNormalizedBand) in toBandTable {
            if toNormalizedBand == normalizedBand {
                targetBand = toBand
                break
            }
        }
        
        for (toCup, toNormalizedCup) in toCupTable {
            if toNormalizedCup == normalizedCup {
                targetCup = toCup
                break
            }
        }
        
        guard let finalBand = targetBand, let finalCup = targetCup else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: .women,
                error: .sizeOutOfRange(size, validRange: "30A-44G")
            )
        }
        
        return ConversionResult(
            originalSize: size,
            convertedSize: finalBand + finalCup,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: .women,
            confidence: 0.95,
            notes: generateConversionNotes(from: from, to: to, originalCup: cup, targetCup: finalCup)
        )
    }
    
    /// Validate if a bra size is valid for the given system
    ///
    /// Checks both format (numeric band + letter cup) and existence in conversion tables.
    ///
    /// ## Valid Formats
    /// - **Pattern**: 2-3 digits followed by 1-3 letters
    /// - **Examples**: "30A", "34B", "36DD", "38DDD", "40G"
    /// - **Invalid**: "34", "B", "34Z", "99A"
    ///
    /// - Parameters:
    ///   - size: Size string to validate
    ///   - system: Sizing system to check against
    ///   - gender: Gender context (ignored)
    /// - Returns: True if size is valid and convertible
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        guard let (band, cup) = parseBraSize(size.normalizedSize) else { return false }
        return bandConversions[system]?.keys.contains(band) == true &&
        cupConversions[system]?.keys.contains(cup) == true
    }
    
    /// Get suggestions for invalid or ambiguous bra sizes
    ///
    /// Provides helpful alternatives when a size cannot be validated.
    /// Returns common bra sizes as examples.
    ///
    /// - Parameters:
    ///   - size: Invalid size string
    ///   - system: Target sizing system
    ///   - gender: Gender context (ignored)
    /// - Returns: Array of suggested valid bra sizes
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["32A", "34B", "36C", "38D"]
    }
    
    // MARK: - Private Helper Methods
    
    /// Parse a bra size string into band and cup components
    ///
    /// Uses regex to extract numeric band and letter cup from combined size.
    /// Handles various input formats and normalizes them.
    ///
    /// ## Regex Pattern
    /// `^(\d{2,3})([A-K]+)$`
    /// - `(\d{2,3})`: Captures 2-3 digits for band size
    /// - `([A-K]+)`: Captures 1+ letters A-K for cup size
    ///
    /// ## Examples
    /// - "34B" → ("34", "B")
    /// - "36DD" → ("36", "DD")
    /// - "38DDD" → ("38", "DDD")
    /// - "Invalid" → nil
    ///
    /// - Parameter size: Normalized bra size string
    /// - Returns: Tuple of (band, cup) strings, or nil if parsing fails
    private func parseBraSize(_ size: String) -> (band: String, cup: String)? {
        let pattern = #"^(\d{2,3})([A-K]+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: size, range: NSRange(size.startIndex..., in: size)) else {
            return nil
        }
        
        let bandRange = Range(match.range(at: 1), in: size)!
        let cupRange = Range(match.range(at: 2), in: size)!
        
        return (String(size[bandRange]), String(size[cupRange]))
    }
    
    /// Generate helpful notes about the conversion
    ///
    /// Provides context about regional cup size differences and
    /// any notable changes in the conversion.
    ///
    /// ## Note Categories
    /// - Cup size changes (DD vs E, DDD vs E, etc.)
    /// - Regional sizing differences
    /// - Band measurement systems (inches vs cm)
    /// - Fit variation warnings
    ///
    /// - Parameters:
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - originalCup: Original cup size
    ///   - targetCup: Converted cup size
    /// - Returns: Optional notes string with conversion context
    private func generateConversionNotes(from: SizeSystem, to: SizeSystem, originalCup: String, targetCup: String) -> String? {
        var notes: [String] = []
        
        // Note cup size changes
        if originalCup != targetCup {
            if originalCup == "DDD" && targetCup == "E" {
                notes.append("UK uses 'E' instead of 'DDD'")
            } else if originalCup == "DD" && targetCup == "E" {
                notes.append("EU uses 'E' for DD cup sizes")
            } else if originalCup != targetCup {
                notes.append("Cup designation changed from '\(originalCup)' to '\(targetCup)'")
            }
        }
        
        // Note measurement system differences
        if from == .us && to == .eu {
            notes.append("EU uses centimeter measurements for band sizes")
        } else if from == .us && to == .au {
            notes.append("AU uses dress size numbering for band sizes")
        } else if from == .us && to == .fr {
            notes.append("French sizing adds 15cm to EU measurements")
        }
        
        // General fit warning
        if to != from {
            notes.append("Bra fit can vary between brands and regions")
        }
        
        return notes.isEmpty ? nil : notes.joined(separator: ". ")
    }
    
}
