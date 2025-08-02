//
//  SizeConverterProtocol.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


/// Protocol for size converters
internal protocol SizeConverterProtocol: Sendable {
    /// Convert a size between systems
    func convert(
        size: String,
        from: SizeSystem,
        to: SizeSystem,
        gender: Gender
    ) -> String?
    
    /// Convert with detailed results
    func convertWithDetails(
        size: String,
        from: SizeSystem,
        to: SizeSystem,
        gender: Gender,
        type: SizeType
    ) -> ConversionResult
    
    /// Validate a size
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool
    
    /// Get suggestions for invalid sizes
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String]
    
    /// Get supported systems
    var supportedSystems: [SizeSystem] { get }
    
    /// Whether gender is required for this converter
    var requiresGender: Bool { get }
}