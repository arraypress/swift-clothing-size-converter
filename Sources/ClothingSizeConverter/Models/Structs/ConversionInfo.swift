//
//  ConversionInfo.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


/// Comprehensive information about converter capabilities
public struct ConversionInfo: Sendable {
    /// All supported clothing/accessory types
    public let supportedTypes: [SizeType]
    
    /// All supported sizing systems
    public let supportedSystems: [SizeSystem]
    
    /// All supported gender contexts
    public let supportedGenders: [Gender]
    
    /// Map of size types to their supported systems
    public let systemsByType: [SizeType: [SizeSystem]]
    
    /// Description of the converter
    public let description: String
    
    /// Total number of possible conversions
    public var totalConversions: Int {
        return systemsByType.values.reduce(0) { total, systems in
            total + (systems.count * (systems.count - 1))
        }
    }
}