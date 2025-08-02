//
//  ConversionResult.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

/// Detailed conversion result with metadata
public struct ConversionResult: Sendable {
    /// Original size that was converted
    public let originalSize: String
    
    /// Converted size (nil if conversion failed)
    public let convertedSize: String?
    
    /// Source sizing system
    public let fromSystem: SizeSystem
    
    /// Target sizing system
    public let toSystem: SizeSystem
    
    /// Type of clothing/accessory
    public let type: SizeType
    
    /// Gender context used
    public let gender: Gender
    
    /// Confidence level of conversion (0.0 - 1.0)
    public let confidence: Double
    
    /// Error if conversion failed
    public let error: ConversionError?
    
    /// Additional notes about the conversion
    public let notes: String?
    
    /// Whether the conversion was successful
    public var isSuccess: Bool {
        return convertedSize != nil && error == nil
    }
    
    /// Suggested size range (for when exact conversion isn't certain)
    public let suggestedRange: String?
    
    /// Initialize a successful conversion result
    public init(
        originalSize: String,
        convertedSize: String,
        fromSystem: SizeSystem,
        toSystem: SizeSystem,
        type: SizeType,
        gender: Gender,
        confidence: Double = 1.0,
        notes: String? = nil,
        suggestedRange: String? = nil
    ) {
        self.originalSize = originalSize
        self.convertedSize = convertedSize
        self.fromSystem = fromSystem
        self.toSystem = toSystem
        self.type = type
        self.gender = gender
        self.confidence = confidence
        self.error = nil
        self.notes = notes
        self.suggestedRange = suggestedRange
    }
    
    /// Initialize a failed conversion result
    public init(
        originalSize: String,
        convertedSize: String? = nil,
        fromSystem: SizeSystem,
        toSystem: SizeSystem,
        type: SizeType,
        gender: Gender,
        confidence: Double = 0.0,
        error: ConversionError,
        notes: String? = nil
    ) {
        self.originalSize = originalSize
        self.convertedSize = convertedSize
        self.fromSystem = fromSystem
        self.toSystem = toSystem
        self.type = type
        self.gender = gender
        self.confidence = confidence
        self.error = error
        self.notes = notes
        self.suggestedRange = nil
    }
}
