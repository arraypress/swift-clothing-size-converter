//
//  ShoeConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


//
//  ShoeConverter.swift
//  ClothingSizeConverter
//
//  Shoe size converter with comprehensive international support
//  Created on 28/07/2025.
//

import Foundation

/// Converter for shoe sizes across international systems
///
/// Supports conversion between US, UK, EU, AU, JP, and CM sizing systems
/// for both men's and women's shoes. Handles half sizes and provides
/// confidence scoring for conversion accuracy.
///
/// ## Supported Systems
/// - **US**: Standard US shoe sizing (4-18)
/// - **UK**: British shoe sizing (1.5-17.5)  
/// - **EU**: European shoe sizing (34-53)
/// - **AU**: Australian shoe sizing (same as UK)
/// - **JP**: Japanese shoe sizing in centimeters (21-36)
/// - **CM**: Direct centimeter measurements (21-36)
///
/// ## Example Usage
/// ```swift
/// let converter = ShoeConverter()
/// 
/// // Convert US women's 9 to EU
/// let result = converter.convert(size: "9", from: .us, to: .eu, gender: .women)
/// // Result: "39"
/// 
/// // Get detailed conversion information
/// let detailed = converter.convertWithDetails(
///     size: "9.5", 
///     from: .us, 
///     to: .eu, 
///     gender: .women, 
///     type: .shoe
/// )
/// print("Confidence: \(detailed.confidence)")
/// ```
internal struct ShoeConverter: SizeConverterProtocol {
    
    // MARK: - Protocol Properties
    
    /// Sizing systems supported by this converter
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .au, .jp, .cm]
    }
    
    /// Whether gender context is required for accurate conversion
    var requiresGender: Bool {
        return true
    }
    
    // MARK: - Conversion Tables
    
    /// Men's shoe size conversion table
    ///
    /// Maps sizes from different systems to normalized US sizes for conversion.
    /// All values represent the equivalent US men's size for cross-reference.
    private let menConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "4": 4.0, "4.5": 4.5, "5": 5.0, "5.5": 5.5, "6": 6.0, "6.5": 6.5,
            "7": 7.0, "7.5": 7.5, "8": 8.0, "8.5": 8.5, "9": 9.0, "9.5": 9.5,
            "10": 10.0, "10.5": 10.5, "11": 11.0, "11.5": 11.5, "12": 12.0,
            "12.5": 12.5, "13": 13.0, "13.5": 13.5, "14": 14.0, "14.5": 14.5,
            "15": 15.0, "16": 16.0, "17": 17.0, "18": 18.0
        ],
        .uk: [
            "3.5": 4.0, "4": 4.5, "4.5": 5.0, "5": 5.5, "5.5": 6.0, "6": 6.5,
            "6.5": 7.0, "7": 7.5, "7.5": 8.0, "8": 8.5, "8.5": 9.0, "9": 9.5,
            "9.5": 10.0, "10": 10.5, "10.5": 11.0, "11": 11.5, "11.5": 12.0,
            "12": 12.5, "12.5": 13.0, "13": 13.5, "13.5": 14.0, "14": 14.5,
            "14.5": 15.0, "15.5": 16.0, "16.5": 17.0, "17.5": 18.0
        ],
        .eu: [
            "36": 4.0, "36.5": 4.5, "37": 5.0, "38": 5.5, "38.5": 6.0, "39": 6.5,
            "40": 7.0, "40.5": 7.5, "41": 8.0, "42": 8.5, "42.5": 9.0, "43": 9.5,
            "44": 10.0, "44.5": 10.5, "45": 11.0, "45.5": 11.5, "46": 12.0,
            "47": 12.5, "47.5": 13.0, "48": 13.5, "48.5": 14.0, "49": 14.5,
            "50": 15.0, "51": 16.0, "52": 17.0, "53": 18.0
        ],
        .au: [
            "3.5": 4.0, "4": 4.5, "4.5": 5.0, "5": 5.5, "5.5": 6.0, "6": 6.5,
            "6.5": 7.0, "7": 7.5, "7.5": 8.0, "8": 8.5, "8.5": 9.0, "9": 9.5,
            "9.5": 10.0, "10": 10.5, "10.5": 11.0, "11": 11.5, "11.5": 12.0,
            "12": 12.5, "12.5": 13.0, "13": 13.5, "13.5": 14.0, "14": 14.5,
            "14.5": 15.0, "15.5": 16.0, "16.5": 17.0, "17.5": 18.0
        ],
        .jp: [
            "22": 4.0, "22.5": 4.5, "23": 5.0, "23.5": 5.5, "24": 6.0, "24.5": 6.5,
            "25": 7.0, "25.5": 7.5, "26": 8.0, "26.5": 8.5, "27": 9.0, "27.5": 9.5,
            "28": 10.0, "28.5": 10.5, "29": 11.0, "29.5": 11.5, "30": 12.0,
            "30.5": 12.5, "31": 13.0, "31.5": 13.5, "32": 14.0, "32.5": 14.5,
            "33": 15.0, "34": 16.0, "35": 17.0, "36": 18.0
        ],
        .cm: [
            "22": 4.0, "22.5": 4.5, "23": 5.0, "23.5": 5.5, "24": 6.0, "24.5": 6.5,
            "25": 7.0, "25.5": 7.5, "26": 8.0, "26.5": 8.5, "27": 9.0, "27.5": 9.5,
            "28": 10.0, "28.5": 10.5, "29": 11.0, "29.5": 11.5, "30": 12.0,
            "30.5": 12.5, "31": 13.0, "31.5": 13.5, "32": 14.0, "32.5": 14.5,
            "33": 15.0, "34": 16.0, "35": 17.0, "36": 18.0
        ]
    ]
    
    /// Women's shoe size conversion table
    ///
    /// Maps sizes from different systems to normalized US sizes for conversion.
    /// Women's sizing typically runs 1.5-2 sizes smaller than men's in US/UK systems.
    private let womenConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "4": 4.0, "4.5": 4.5, "5": 5.0, "5.5": 5.5, "6": 6.0, "6.5": 6.5,
            "7": 7.0, "7.5": 7.5, "8": 8.0, "8.5": 8.5, "9": 9.0, "9.5": 9.5,
            "10": 10.0, "10.5": 10.5, "11": 11.0, "11.5": 11.5, "12": 12.0,
            "12.5": 12.5, "13": 13.0, "13.5": 13.5, "14": 14.0, "15": 15.0,
            "16": 16.0
        ],
        .uk: [
            "1.5": 4.0, "2": 4.5, "2.5": 5.0, "3": 5.5, "3.5": 6.0, "4": 6.5,
            "4.5": 7.0, "5": 7.5, "5.5": 8.0, "6": 8.5, "6.5": 9.0, "7": 9.5,
            "7.5": 10.0, "8": 10.5, "8.5": 11.0, "9": 11.5, "9.5": 12.0,
            "10": 12.5, "10.5": 13.0, "11": 13.5, "11.5": 14.0, "12.5": 15.0,
            "13.5": 16.0
        ],
        .eu: [
            "34": 4.0, "34.5": 4.5, "35": 5.0, "35.5": 5.5, "36": 6.0, "36.5": 6.5,
            "37": 7.0, "37.5": 7.5, "38": 8.0, "38.5": 8.5, "39": 9.0, "39.5": 9.5,
            "40": 10.0, "40.5": 10.5, "41": 11.0, "41.5": 11.5, "42": 12.0,
            "42.5": 12.5, "43": 13.0, "43.5": 13.5, "44": 14.0, "45": 15.0,
            "46": 16.0
        ],
        .au: [
            "1.5": 4.0, "2": 4.5, "2.5": 5.0, "3": 5.5, "3.5": 6.0, "4": 6.5,
            "4.5": 7.0, "5": 7.5, "5.5": 8.0, "6": 8.5, "6.5": 9.0, "7": 9.5,
            "7.5": 10.0, "8": 10.5, "8.5": 11.0, "9": 11.5, "9.5": 12.0,
            "10": 12.5, "10.5": 13.0, "11": 13.5, "11.5": 14.0, "12.5": 15.0,
            "13.5": 16.0
        ],
        .jp: [
            "21": 4.0, "21.5": 4.5, "22": 5.0, "22.5": 5.5, "23": 6.0, "23.5": 6.5,
            "24": 7.0, "24.5": 7.5, "25": 8.0, "25.5": 8.5, "26": 9.0, "26.5": 9.5,
            "27": 10.0, "27.5": 10.5, "28": 11.0, "28.5": 11.5, "29": 12.0,
            "29.5": 12.5, "30": 13.0, "30.5": 13.5, "31": 14.0, "32": 15.0,
            "33": 16.0
        ],
        .cm: [
            "21": 4.0, "21.5": 4.5, "22": 5.0, "22.5": 5.5, "23": 6.0, "23.5": 6.5,
            "24": 7.0, "24.5": 7.5, "25": 8.0, "25.5": 8.5, "26": 9.0, "26.5": 9.5,
            "27": 10.0, "27.5": 10.5, "28": 11.0, "28.5": 11.5, "29": 12.0,
            "29.5": 12.5, "30": 13.0, "30.5": 13.5, "31": 14.0, "32": 15.0,
            "33": 16.0
        ]
    ]
    
    // MARK: - Public Methods
    
    /// Convert a shoe size between systems
    ///
    /// Performs a simple conversion without detailed metadata.
    /// For more information about the conversion, use `convertWithDetails`.
    ///
    /// - Parameters:
    ///   - size: Source shoe size (e.g., "9", "9.5", "42")
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context (.men, .women, .unisex defaults to men's)
    /// - Returns: Converted size string, or nil if conversion fails
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        let result = convertWithDetails(size: size, from: from, to: to, gender: gender, type: .shoe)
        return result.convertedSize
    }
    
    /// Convert shoe size with detailed conversion information
    ///
    /// Provides comprehensive conversion results including confidence scores,
    /// notes about sizing variations, and error details if conversion fails.
    ///
    /// ## Conversion Process
    /// 1. Normalize input size (handle fractions, whitespace)
    /// 2. Validate source and target systems are supported
    /// 3. Handle same-system conversions
    /// 4. Convert via normalized US size reference
    /// 5. Apply confidence scoring based on system reliability
    /// 6. Provide extrapolation for extended sizes if needed
    ///
    /// - Parameters:
    ///   - size: Source shoe size to convert
    ///   - from: Source sizing system
    ///   - to: Target sizing system  
    ///   - gender: Gender context for sizing differences
    ///   - type: Size type (should be .shoe for this converter)
    /// - Returns: Detailed conversion result with metadata
    func convertWithDetails(
        size: String,
        from: SizeSystem,
        to: SizeSystem,
        gender: Gender,
        type: SizeType
    ) -> ConversionResult {
        
        // Normalize input
        let normalizedSize = size.normalizedSize
        
        // Check if systems are supported
        guard supportedSystems.contains(from) else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .unsupportedSystem(from, for: type)
            )
        }
        
        guard supportedSystems.contains(to) else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .unsupportedSystem(to, for: type)
            )
        }
        
        // Handle same system conversion
        if from == to {
            if isValid(size: normalizedSize, system: from, gender: gender) {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: normalizedSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: 1.0,
                    notes: "Same sizing system"
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
        
        // Get appropriate conversion table
        let conversions = getConversions(for: gender)
        
        // Find the normalized US size (our base system)
        guard let fromTable = conversions[from],
              let usSize = fromTable[normalizedSize] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size),
                notes: "Size not found in \(from.fullName) table"
            )
        }
        
        // Convert from US size to target system
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
        
        // Find the target size
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 { // Allow for small floating point differences
                let confidence = calculateConfidence(from: from, to: to, size: normalizedSize)
                let notes = generateNotes(from: from, to: to, gender: gender)
                
                return ConversionResult(
                    originalSize: size,
                    convertedSize: targetSize,
                    fromSystem: from,
                    toSystem: to,
                    type: type,
                    gender: gender,
                    confidence: confidence,
                    notes: notes
                )
            }
        }
        
        // If exact match not found, try extrapolation for extended sizes
        if let extrapolated = extrapolateSize(usSize: usSize, to: to, gender: gender) {
            return ConversionResult(
                originalSize: size,
                convertedSize: extrapolated,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                confidence: 0.7,
                notes: "Extended size - extrapolated conversion"
            )
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: getValidRange(for: from, gender: gender))
        )
    }
    
    /// Validate if a shoe size is valid for the given system and gender
    ///
    /// Checks both format (numeric pattern) and existence in conversion tables.
    ///
    /// - Parameters:
    ///   - size: Size string to validate
    ///   - system: Sizing system to check against
    ///   - gender: Gender context for validation
    /// - Returns: True if size is valid and convertible
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalizedSize = size.normalizedSize
        
        // Check pattern first
        guard normalizedSize.matches(SizePatterns.shoeSize) else {
            return false
        }
        
        // Check if size exists in conversion table
        let conversions = getConversions(for: gender)
        return conversions[system]?.keys.contains(normalizedSize) == true
    }
    
    /// Get suggestions for invalid or ambiguous shoe sizes
    ///
    /// Provides helpful alternatives when a size cannot be validated.
    /// Includes decimal equivalents for fractions and nearby valid sizes.
    ///
    /// - Parameters:
    ///   - size: Invalid size string
    ///   - system: Target sizing system
    ///   - gender: Gender context for suggestions
    /// - Returns: Array of suggested valid sizes
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        let normalizedSize = size.normalizedSize
        var suggestions: [String] = []
        
        // If size has fraction, suggest decimal equivalent
        if size.hasFraction {
            suggestions.append(size.normalizedSize)
        }
        
        // If size is numeric, suggest nearby sizes
        if let numericValue = normalizedSize.numericValue {
            let conversions = getConversions(for: gender)
            if let systemTable = conversions[system] {
                let allSizes = systemTable.keys.compactMap { Double($0) }.sorted()
                
                // Find closest sizes
                for candidateSize in allSizes {
                    if abs(candidateSize - numericValue) <= 1.0 {
                        suggestions.append(String(candidateSize))
                    }
                }
            }
        }
        
        // Remove duplicates and limit to 5 suggestions
        return Array(Set(suggestions)).prefix(5).map { $0 }
    }
    
    // MARK: - Private Helper Methods
    
    /// Get the appropriate conversion table for the specified gender
    ///
    /// - Parameter gender: Gender context (.unisex and .children default to men's)
    /// - Returns: Conversion table mapping systems to size dictionaries
    private func getConversions(for gender: Gender) -> [SizeSystem: [String: Double]] {
        switch gender {
        case .men, .unisex, .children:
            return menConversions
        case .women:
            return womenConversions
        case .infant, .toddler, .youth:
            // Children's shoes typically follow adult men's sizing
            return menConversions
        }
    }
    
    /// Calculate confidence score for a conversion
    ///
    /// Factors that affect confidence:
    /// - System reliability (US/UK/EU more reliable than JP/CN/KR)
    /// - Measurement vs. sizing systems
    /// - Extreme sizes (very small/large have lower confidence)
    ///
    /// - Parameters:
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - size: Size being converted
    /// - Returns: Confidence score from 0.5 to 0.95
    private func calculateConfidence(from: SizeSystem, to: SizeSystem, size: String) -> Double {
        // Base confidence is high for standard conversions
        var confidence = 0.95
        
        // Lower confidence for less common systems
        if [.jp, .cn, .kr].contains(from) || [.jp, .cn, .kr].contains(to) {
            confidence -= 0.1
        }
        
        // Lower confidence for measurement systems
        if from.isMeasurement || to.isMeasurement {
            confidence -= 0.05
        }
        
        // Check if size is at the extreme ends (less reliable)
        if let numericValue = size.normalizedSize.numericValue {
            if numericValue <= 5.0 || numericValue >= 13.0 {
                confidence -= 0.1
            }
        }
        
        return max(0.5, confidence)
    }
    
    /// Generate helpful notes about the conversion
    ///
    /// Provides context about sizing differences between systems
    /// and brand variation warnings where appropriate.
    ///
    /// - Parameters:
    ///   - from: Source sizing system
    ///   - to: Target sizing system
    ///   - gender: Gender context
    /// - Returns: Optional notes string
    private func generateNotes(from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        var notes: [String] = []
        
        if from == .us && to == .uk {
            notes.append("UK sizes typically run 0.5 smaller than US")
        } else if from == .uk && to == .us {
            notes.append("US sizes typically run 0.5 larger than UK")
        }
        
        if to == .eu {
            notes.append("European sizes are consistent across most brands")
        }
        
        if to == .jp || to == .cm {
            notes.append("Japanese/CM sizes based on foot length measurement")
        }
        
        if gender == .women {
            notes.append("Women's shoe sizing can vary significantly between brands")
        }
        
        return notes.isEmpty ? nil : notes.joined(separator: ". ")
    }
    
    /// Extrapolate sizes beyond the standard conversion table
    ///
    /// Uses linear extrapolation for very large or small sizes that
    /// aren't in the standard conversion tables.
    ///
    /// - Parameters:
    ///   - usSize: Normalized US size to extrapolate from
    ///   - to: Target sizing system
    ///   - gender: Gender context
    /// - Returns: Extrapolated size string, or nil if extrapolation fails
    private func extrapolateSize(usSize: Double, to: SizeSystem, gender: Gender) -> String? {
        // Simple linear extrapolation for sizes beyond our table
        let conversions = getConversions(for: gender)
        guard let toTable = conversions[to] else { return nil }
        
        let sortedSizes = toTable.sorted { $0.value < $1.value }
        
        if let largest = sortedSizes.last, usSize > largest.value {
            // Extrapolate upward
            let secondLargest = sortedSizes[sortedSizes.count - 2]
            let increment = largest.value - secondLargest.value
            let steps = Int((usSize - largest.value) / increment)
            
            if let largestNumeric = Double(largest.key) {
                let extrapolated = largestNumeric + (Double(steps) * (Double(largest.key)! - Double(secondLargest.key)!))
                return String(format: "%.1f", extrapolated)
            }
        }
        
        return nil
    }
    
    /// Get the valid size range for a system and gender
    ///
    /// - Parameters:
    ///   - system: Sizing system to check
    ///   - gender: Gender context
    /// - Returns: Human-readable size range string
    private func getValidRange(for system: SizeSystem, gender: Gender) -> String {
        let conversions = getConversions(for: gender)
        guard let systemTable = conversions[system] else { return "Unknown" }
        
        let sizes = systemTable.keys.compactMap { Double($0) }.sorted()
        if let min = sizes.first, let max = sizes.last {
            return "\(min) - \(max)"
        }
        
        return "Unknown"
    }
}