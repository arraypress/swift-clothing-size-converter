//
//  SwimwearConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

/// Converter for swimwear sizes with gender-specific differences
///
/// Swimwear sizing differs from regular clothing, especially for women's pieces
/// which may include cup sizing like bras or use different letter size mappings.
internal struct SwimwearConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .au] }
    var requiresGender: Bool { true }
    
    // Updated conversion tables - mapping each system's sizes to a normalized US numeric value
    private let womenSwimwearConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XS": 2, "S": 4, "M": 6, "L": 10, "XL": 14, "XXL": 18,
            "32A": 2, "32B": 2, "34A": 4, "34B": 4, "34C": 6, "36B": 6, "36C": 8, "38B": 10, "38C": 12, "40B": 14, "40C": 16
        ],
        .uk: [
            "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18
        ],
        .eu: [
            "32": 2, "34": 4, "36": 6, "38": 8, "40": 10, "42": 12, "44": 14, "46": 16, "48": 18
        ],
        .au: [
            "6": 2, "8": 4, "10": 6, "12": 8, "14": 10, "16": 12, "18": 14, "20": 16, "22": 18
        ]
    ]
    
    private let menSwimwearConversions: [SizeSystem: [String: Double]] = [
        .us: [
            "XS": 28, "S": 30, "M": 32, "L": 34, "XL": 36, "XXL": 38,
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38, "40": 40
        ],
        .uk: [
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38
        ],
        .eu: [
            "44": 28, "46": 30, "48": 32, "50": 34, "52": 36, "54": 38
        ],
        .au: [
            "28": 28, "30": 30, "32": 32, "34": 34, "36": 36, "38": 38
        ]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .swimwear).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = size.normalizedSize
        let conversions = gender == .women ? womenSwimwearConversions : menSwimwearConversions
        
        // Same system conversion
        if from == to {
            if conversions[from]?.keys.contains(normalized) == true {
                return ConversionResult(
                    originalSize: size,
                    convertedSize: normalized,
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
        
        guard let fromTable = conversions[from],
              let toTable = conversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .unsupportedSystem(from, for: type)
            )
        }
        
        guard let normalizedValue = fromTable[normalized] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        // Find the target size by matching the normalized value
        for (targetSize, targetValue) in toTable {
            if abs(targetValue - normalizedValue) < 0.01 {
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
