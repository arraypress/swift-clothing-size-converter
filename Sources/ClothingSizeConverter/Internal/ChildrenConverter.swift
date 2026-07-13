//
//  ChildrenConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Converter for children's clothing sizes across age groups
///
/// Supports infant (0-24M), toddler (2T-5T), children's (4-20), and youth (XS-XL) sizing.
/// Each age group uses different sizing conventions based on age and height.
internal struct ChildrenConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .fr] }
    
    // Age-based conversion tables for different children's categories
    private let infantConversions: [SizeSystem: [String: Double]] = [
        .us: ["0M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24],
        .uk: ["0M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24],
        .eu: ["50": 0, "56": 3, "62": 6, "68": 9, "74": 12, "80": 18, "86": 24],
        .fr: ["1M": 0, "3M": 3, "6M": 6, "9M": 9, "12M": 12, "18M": 18, "24M": 24]
    ]
    
    private let toddlerConversions: [SizeSystem: [String: Double]] = [
        .us: ["2T": 2, "3T": 3, "4T": 4, "5T": 5],
        .uk: ["2": 2, "3": 3, "4": 4, "5": 5],
        .eu: ["92": 2, "98": 3, "104": 4, "110": 5],
        .fr: ["2A": 2, "3A": 3, "4A": 4, "5A": 5]
    ]
    
    private let childrenConversions: [SizeSystem: [String: Double]] = [
        .us: ["4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "10": 10, "12": 12, "14": 14, "16": 16, "18": 18, "20": 20],
        .uk: ["4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "10": 10, "12": 12, "14": 14, "16": 16, "18": 18, "20": 20],
        .eu: ["104": 4, "110": 5, "116": 6, "122": 7, "128": 8, "140": 10, "152": 12, "164": 14, "170": 16, "176": 18, "182": 20],
        .fr: ["4A": 4, "5A": 5, "6A": 6, "7A": 7, "8A": 8, "10A": 10, "12A": 12, "14A": 14, "16A": 16, "18A": 18, "20A": 20]
    ]
    
    private let youthConversions: [SizeSystem: [String: Double]] = [
        .us: ["XS": 6, "S": 8, "M": 10, "L": 12, "XL": 14],
        .uk: ["XS": 6, "S": 8, "M": 10, "L": 12, "XL": 14],
        .eu: ["116": 6, "128": 8, "140": 10, "152": 12, "164": 14],
        .fr: ["6A": 6, "8A": 8, "10A": 10, "12A": 12, "14A": 14]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .clothing).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let normalized = size.normalizedSize

        // Pick the age-group table from the caller's gender first, then fall back
        // to any table that actually contains the size. Selecting by gender is
        // what makes non-US inputs work: a European infant height ("62"), a UK
        // toddler ("3"), or an EU children's height ("104") is indistinguishable
        // from a plain children's number by format alone, so the old regex-based
        // routing silently mis-classified every non-US children's size.
        let allTables = [infantConversions, toddlerConversions, childrenConversions, youthConversions]
        let ordered = table(for: gender).map { [$0] + allTables } ?? allTables

        guard let conversions = ordered.first(where: { $0[from]?[normalized] != nil }) else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidFormat(size, expectedFormat: "3M, 2T, 4, XS")
            )
        }

        guard let fromTable = conversions[from],
              let usSize = fromTable[normalized],
              let toTable = conversions[to] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        if let targetSize = toTable.sizeKey(matching: usSize, preferring: normalized) {
            return ConversionResult(
                originalSize: size,
                convertedSize: targetSize,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                confidence: 0.9,
                notes: "Children's sizing based on age/height"
            )
        }

        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "Age-appropriate sizes")
        )
    }

    /// The conversion table implied by a children's gender category, or `nil`
    /// for non-children genders (in which case the caller scans all tables).
    private func table(for gender: Gender) -> [SizeSystem: [String: Double]]? {
        switch gender {
        case .infant:   return infantConversions
        case .toddler:  return toddlerConversions
        case .youth:    return youthConversions
        case .children: return childrenConversions
        default:        return nil
        }
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let normalized = size.normalizedSize
        let allTables = [infantConversions, toddlerConversions, childrenConversions, youthConversions]
        
        for table in allTables {
            if table[system]?.keys.contains(normalized) == true {
                return true
            }
        }
        return false
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        if size.contains("M") {
            return ["3M", "6M", "12M", "18M", "24M"]
        } else if size.contains("T") {
            return ["2T", "3T", "4T", "5T"]
        } else if size.matches(SizePatterns.youthSize) {
            return ["XS", "S", "M", "L", "XL"]
        } else {
            return ["4", "6", "8", "10", "12", "14"]
        }
    }
}
