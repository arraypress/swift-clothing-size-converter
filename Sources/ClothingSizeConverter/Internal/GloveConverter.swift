//
//  GloveConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Converter for glove sizes with letter and numeric support
///
/// Supports XS-XL letter sizes and numeric sizes 6-10.
/// Most systems use universal letter sizing.
internal struct GloveConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu] }
    
    private let conversions: [SizeSystem: [String: String]] = [
        .us: ["XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL", "6": "XS", "7": "S", "8": "M", "9": "L", "10": "XL"],
        .uk: ["XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL"],
        .eu: ["6": "XS", "7": "S", "8": "M", "9": "L", "10": "XL", "XS": "XS", "S": "S", "M": "M", "L": "L", "XL": "XL"]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        guard let fromTable = conversions[from], let targetSize = fromTable[size.normalizedSize] else { return nil }
        return conversions[to]?[targetSize]
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 0.9)
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        return conversions[system]?.keys.contains(size.normalizedSize) == true
    }
    
    /// The sizes this system actually has.
    ///
    /// EU gloves are numbered and UK ones are lettered, so the one hardcoded
    /// list could not have been right for both. The table maps every spelling
    /// onto a letter, so ordering by that letter puts numerals in size order
    /// rather than alphabetical.
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        guard let table = conversions[system] else { return [] }
        let ladder = ["XS", "S", "M", "L", "XL"]
        return table.keys.sorted { left, right in
            let leftRank = ladder.firstIndex(of: table[left] ?? "") ?? 0
            let rightRank = ladder.firstIndex(of: table[right] ?? "") ?? 0
            if leftRank != rightRank { return leftRank < rightRank }
            return left.count == right.count ? left < right : left.count < right.count
        }
    }
}
