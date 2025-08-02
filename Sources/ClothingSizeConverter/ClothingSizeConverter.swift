//
//  ClothingSizeConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


//
//  ClothingSizeConverter.swift
//  ClothingSizeConverter
//
//  A comprehensive clothing size converter with extensive customization options
//  Created on 28/07/2025.
//

import Foundation

// MARK: - Main Public API

public struct ClothingSizeConverter {
    
    /// Convert a size with default settings.
    ///
    /// Converts between sizing systems using industry-standard conversion tables.
    /// Supports shoes, clothing, bras, and accessories with regional variations.
    ///
    /// ## Example
    /// ```swift
    /// let result = ClothingSizeConverter.convert(
    ///     "9.5", 
    ///     from: .us, 
    ///     to: .eu, 
    ///     type: .shoe, 
    ///     gender: .women
    /// )
    /// // Result: "40.5"
    /// ```
    ///
    /// - Parameters:
    ///   - size: Size to convert (e.g., "9.5", "34B", "M")
    ///   - fromSystem: Source sizing system
    ///   - toSystem: Target sizing system  
    ///   - type: Type of clothing/accessory
    ///   - gender: Gender context for sizing
    /// - Returns: Converted size string, or nil if conversion fails
    public static func convert(
        _ size: String,
        from fromSystem: SizeSystem,
        to toSystem: SizeSystem,
        type: SizeType,
        gender: Gender = .unisex
    ) -> String? {
        
        // Use children's converter for children's sizes
        if gender.isChildrens {
            if let childrenConverter = getChildrensConverter(for: gender) {
                return childrenConverter.convert(
                    size: size,
                    from: fromSystem,
                    to: toSystem,
                    gender: gender
                )
            }
        }
        
        guard let converter = getConverter(for: type) else { return nil }
        
        return converter.convert(
            size: size,
            from: fromSystem,
            to: toSystem,
            gender: gender
        )
    }
    
    /// Convert with detailed results and metadata.
    ///
    /// Provides comprehensive conversion information including confidence
    /// levels, notes, and validation details.
    ///
    /// ## Example
    /// ```swift
    /// let result = ClothingSizeConverter.convertWithDetails(
    ///     "34B",
    ///     from: .us,
    ///     to: .uk,
    ///     type: .bra
    /// )
    /// print("Confidence: \(result.confidence)")
    /// print("Notes: \(result.notes ?? "None")")
    /// ```
    ///
    /// - Parameters:
    ///   - size: Size to convert
    ///   - fromSystem: Source sizing system
    ///   - toSystem: Target sizing system
    ///   - type: Type of clothing/accessory
    ///   - gender: Gender context for sizing
    /// - Returns: Detailed conversion result with metadata
    public static func convertWithDetails(
        _ size: String,
        from fromSystem: SizeSystem,
        to toSystem: SizeSystem,
        type: SizeType,
        gender: Gender = .unisex
    ) -> ConversionResult {
        
        // Use children's converter for children's sizes
        if gender.isChildrens {
            if let childrenConverter = getChildrensConverter(for: gender) {
                return childrenConverter.convertWithDetails(
                    size: size,
                    from: fromSystem,
                    to: toSystem,
                    gender: gender,
                    type: type
                )
            }
        }
        
        guard let converter = getConverter(for: type) else {
            return ConversionResult(
                originalSize: size,
                convertedSize: nil,
                fromSystem: fromSystem,
                toSystem: toSystem,
                type: type,
                gender: gender,
                confidence: 0.0,
                error: .unsupportedType(type),
                notes: "No converter available for \(type.rawValue)"
            )
        }
        
        return converter.convertWithDetails(
            size: size,
            from: fromSystem,
            to: toSystem,
            gender: gender,
            type: type
        )
    }
    
    /// Convert multiple sizes efficiently.
    ///
    /// Batch converts multiple sizes using the same parameters.
    /// Failed conversions return nil in the results array.
    ///
    /// ## Example
    /// ```swift
    /// let sizes = ["8", "9", "10", "11"]
    /// let results = ClothingSizeConverter.convertMultiple(
    ///     sizes,
    ///     from: .us,
    ///     to: .eu, 
    ///     type: .shoe,
    ///     gender: .women
    /// )
    /// // Result: ["38.5", "40", "41", "42"]
    /// ```
    ///
    /// - Parameters:
    ///   - sizes: Array of sizes to convert (1-100, automatically clamped)
    ///   - fromSystem: Source sizing system
    ///   - toSystem: Target sizing system
    ///   - type: Type of clothing/accessory
    ///   - gender: Gender context for sizing
    /// - Returns: Array of converted sizes (nil for failed conversions)
    public static func convertMultiple(
        _ sizes: [String],
        from fromSystem: SizeSystem,
        to toSystem: SizeSystem,
        type: SizeType,
        gender: Gender = .unisex
    ) -> [String?] {
        
        let clampedSizes = Array(sizes.prefix(100))
        
        return clampedSizes.map { size in
            convert(size, from: fromSystem, to: toSystem, type: type, gender: gender)
        }
    }
    
    /// Validate if a size is valid for the given system and type.
    ///
    /// Checks size format, range, and compatibility with the sizing system.
    ///
    /// ## Example
    /// ```swift
    /// let isValid = ClothingSizeConverter.isValid("34B", for: .bra, system: .us)
    /// // Result: true
    /// 
    /// let isInvalid = ClothingSizeConverter.isValid("99", for: .shoe, system: .us)
    /// // Result: false
    /// ```
    ///
    /// - Parameters:
    ///   - size: Size string to validate
    ///   - type: Type of clothing/accessory
    ///   - system: Sizing system context
    ///   - gender: Gender context for validation
    /// - Returns: True if size is valid for the given parameters
    public static func isValid(
        _ size: String,
        for type: SizeType,
        system: SizeSystem,
        gender: Gender = .unisex
    ) -> Bool {
        
        // Use children's converter for children's sizes
        if gender.isChildrens {
            if let childrenConverter = getChildrensConverter(for: gender) {
                return childrenConverter.isValid(size: size, system: system, gender: gender)
            }
        }
        
        guard let converter = getConverter(for: type) else { return false }
        return converter.isValid(size: size, system: system, gender: gender)
    }
    
    /// Get size suggestions for invalid or ambiguous inputs.
    ///
    /// Provides helpful suggestions when a size cannot be validated or converted.
    ///
    /// ## Example
    /// ```swift
    /// let suggestions = ClothingSizeConverter.getSuggestions(
    ///     for: "9 1/2",
    ///     type: .shoe,
    ///     system: .us
    /// )
    /// // Result: ["9.5", "9-1/2"]
    /// ```
    ///
    /// - Parameters:
    ///   - size: Invalid or ambiguous size
    ///   - type: Type of clothing/accessory
    ///   - system: Sizing system context
    ///   - gender: Gender context
    /// - Returns: Array of suggested valid sizes
    public static func getSuggestions(
        for size: String,
        type: SizeType,
        system: SizeSystem,
        gender: Gender = .unisex
    ) -> [String] {
        
        // Use children's converter for children's sizes
        if gender.isChildrens {
            if let childrenConverter = getChildrensConverter(for: gender) {
                return childrenConverter.getSuggestions(for: size, system: system, gender: gender)
            }
        }
        
        guard let converter = getConverter(for: type) else { return [] }
        return converter.getSuggestions(for: size, system: system, gender: gender)
    }
    
    /// Get comprehensive information about supported conversions.
    ///
    /// Returns metadata about available size types, systems, and capabilities.
    ///
    /// ## Example
    /// ```swift
    /// let info = ClothingSizeConverter.conversionInfo()
    /// print("Supported types: \(info.supportedTypes)")
    /// print("Systems per type: \(info.systemsByType)")
    /// ```
    ///
    /// - Returns: Comprehensive conversion capability information
    public static func conversionInfo() -> ConversionInfo {
        return ConversionInfo(
            supportedTypes: SizeType.allCases,
            supportedSystems: SizeSystem.allCases,
            supportedGenders: Gender.allCases,
            systemsByType: getSystemsByType(),
            description: "Industry-standard clothing size converter with comprehensive international support"
        )
    }
}

// MARK: - Internal Implementation

extension ClothingSizeConverter {
    
    /// Get the appropriate converter for a size type
    internal static func getConverter(for type: SizeType) -> SizeConverterProtocol? {
        switch type {
        case .shoe:
            return ShoeConverter()
        case .clothing, .dress, .jacket:
            return ClothingConverter()
        case .bra:
            return BraConverter()
        case .ring:
            return RingConverter()
        case .hat:
            return HatConverter()
        case .glove:
            return GloveConverter()
        case .belt, .pants:
            return BeltConverter()
        case .sock:
            return SockConverter()
        case .watch:
            return WatchConverter()
        case .swimwear:
            return SwimwearConverter()
        }
    }
    
    /// Get the appropriate converter for children's sizes
    internal static func getChildrensConverter(for gender: Gender) -> SizeConverterProtocol? {
        if gender.isChildrens {
            return ChildrenConverter()
        }
        return nil
    }
    
    /// Get supported systems by type
    internal static func getSystemsByType() -> [SizeType: [SizeSystem]] {
        var systemsByType: [SizeType: [SizeSystem]] = [:]
        
        for type in SizeType.allCases {
            if let converter = getConverter(for: type) {
                systemsByType[type] = converter.supportedSystems
            }
        }
        
        return systemsByType
    }
}

// MARK: - String Extensions

public extension String {
    
    /// Check if this string represents a valid clothing size.
    ///
    /// ## Example
    /// ```swift
    /// "9.5".isClothingSize // true
    /// "XL".isClothingSize // true
    /// "34B".isClothingSize // true
    /// ```
    var isClothingSize: Bool {
        // Quick check for common size patterns
        let patterns = [
            #"^\d+\.?5?$"#,        // Shoe sizes: 9, 9.5
            #"^[XS|S|M|L|XL|XXL]+$"#, // Clothing: XS, S, M, L, XL, XXL
            #"^\d+[A-Z]+$"#,       // Bra sizes: 34B, 36DD
            #"^\d+$"#              // Numeric: 30, 32, 34
        ]
        
        return patterns.contains { pattern in
            self.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    /// Validate size for specific type and system.
    ///
    /// ## Example
    /// ```swift
    /// "9.5".isValidSize(for: .shoe, system: .us, gender: .women) // true
    /// "invalid".isValidSize(for: .shoe, system: .us, gender: .women) // false
    /// ```
    func isValidSize(for type: SizeType, system: SizeSystem, gender: Gender = .unisex) -> Bool {
        return ClothingSizeConverter.isValid(self, for: type, system: system, gender: gender)
    }
    
    /// Convert this size to another system.
    ///
    /// ## Example
    /// ```swift
    /// let converted = "9".convertSize(from: .us, to: .eu, type: .shoe, gender: .women)
    /// // Result: "39"
    /// ```
    func convertSize(
        from fromSystem: SizeSystem,
        to toSystem: SizeSystem,
        type: SizeType,
        gender: Gender = .unisex
    ) -> String? {
        return ClothingSizeConverter.convert(self, from: fromSystem, to: toSystem, type: type, gender: gender)
    }
}

// MARK: - Array Extensions

public extension Array where Element == String {
    
    /// Convert all sizes in the array to another system.
    ///
    /// ## Example
    /// ```swift
    /// let sizes = ["8", "9", "10"]
    /// let converted = sizes.convertSizes(from: .us, to: .eu, type: .shoe, gender: .women)
    /// // Result: ["38", "39", "40"]
    /// ```
    func convertSizes(
        from fromSystem: SizeSystem,
        to toSystem: SizeSystem,
        type: SizeType,
        gender: Gender = .unisex
    ) -> [String?] {
        return ClothingSizeConverter.convertMultiple(self, from: fromSystem, to: toSystem, type: type, gender: gender)
    }
    
    /// Get only the valid sizes for a specific type and system.
    ///
    /// ## Example
    /// ```swift
    /// let sizes = ["8", "9", "invalid", "10.5"]
    /// let valid = sizes.validSizes(for: .shoe, system: .us, gender: .women)
    /// // Result: ["8", "9", "10.5"]
    /// ```
    func validSizes(for type: SizeType, system: SizeSystem, gender: Gender = .unisex) -> [String] {
        return self.filter { size in
            ClothingSizeConverter.isValid(size, for: type, system: system, gender: gender)
        }
    }
    
    /// Get normalized versions of all sizes.
    ///
    /// ## Example
    /// ```swift
    /// let unnormalized = ["9 1/2", "LARGE", "  10  "]
    /// let normalized = unnormalized.normalizedSizes
    /// // Result: ["9.5", "L", "10"]
    /// ```
    var normalizedSizes: [String] {
        return self.map { $0.normalizedSize }
    }
    
    /// Count valid sizes in the collection.
    ///
    /// ## Example
    /// ```swift
    /// let sizes = ["34B", "36C", "invalid", "38D"]
    /// let count = sizes.validSizeCount(for: .bra, system: .us)
    /// // Result: 3
    /// ```
    func validSizeCount(for type: SizeType, system: SizeSystem, gender: Gender = .unisex) -> Int {
        return self.lazy.filter { size in
            ClothingSizeConverter.isValid(size, for: type, system: system, gender: gender)
        }.count
    }
}