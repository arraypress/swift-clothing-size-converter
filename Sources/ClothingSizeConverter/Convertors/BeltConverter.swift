//
//  BeltConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

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
