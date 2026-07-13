//
//  RingConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Converter for ring sizes across international systems.
///
/// Values follow the ISO 8653 relationship between US size and inside
/// circumference (`circumference_mm ≈ 36.5 + 2.55 × US size`). EU and cm express
/// that circumference (in mm and cm), inches is the inside diameter, and JP is
/// the Japanese scale (≈ circumference − 40).
///
/// ## Supported Systems
/// - **US**: Numeric sizes 3-12 (standard US ring sizing)
/// - **UK**: Letter sizes F-X (British alphabetical system)
/// - **EU**: Inside circumference in mm (44-67)
/// - **JP**: Japanese numeric scale (4-27)
/// - **Inches**: Inside diameter in inches (0.554-0.842)
/// - **CM**: Inside circumference in cm (4.42-6.72)
///
/// ## Example Usage
/// ```swift
/// let converter = RingConverter()
///
/// // Convert US size 7 to UK
/// let result = converter.convert(size: "7", from: .us, to: .uk, gender: .unisex)
/// // Result: "N"
///
/// // Convert to metric circumference
/// let cmResult = converter.convert(size: "7", from: .us, to: .cm, gender: .unisex)
/// // Result: "5.44"
/// ```
internal struct RingConverter: SizeConverterProtocol {
    
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .jp, .inches, .cm]
    }

    /// Ring size conversion table mapping all systems to normalized US sizes
    private let conversions: [SizeSystem: [String: Double]] = [
        .us: ["3": 3, "3.5": 3.5, "4": 4, "4.5": 4.5, "5": 5, "5.5": 5.5, "6": 6, "6.5": 6.5, "7": 7, "7.5": 7.5, "8": 8, "8.5": 8.5, "9": 9, "9.5": 9.5, "10": 10, "10.5": 10.5, "11": 11, "11.5": 11.5, "12": 12],
        .uk: ["F": 3, "G": 3.5, "H": 4, "I": 4.5, "J": 5, "K": 5.5, "L": 6, "M": 6.5, "N": 7, "O": 7.5, "P": 8, "Q": 8.5, "R": 9, "S": 9.5, "T": 10, "U": 10.5, "V": 11, "W": 11.5, "X": 12],
        .eu: ["44": 3, "45": 3.5, "47": 4, "48": 4.5, "49": 5, "51": 5.5, "52": 6, "53": 6.5, "54": 7, "56": 7.5, "57": 8, "58": 8.5, "60": 9, "61": 9.5, "62": 10, "63": 10.5, "65": 11, "66": 11.5, "67": 12],
        .jp: ["4": 3, "5": 3.5, "7": 4, "8": 4.5, "9": 5, "11": 5.5, "12": 6, "13": 6.5, "14": 7, "16": 7.5, "17": 8, "18": 8.5, "20": 9, "21": 9.5, "22": 10, "23": 10.5, "25": 11, "26": 11.5, "27": 12],
        .inches: ["0.554": 3, "0.570": 3.5, "0.586": 4, "0.602": 4.5, "0.618": 5, "0.634": 5.5, "0.650": 6, "0.666": 6.5, "0.682": 7, "0.698": 7.5, "0.714": 8, "0.730": 8.5, "0.746": 9, "0.762": 9.5, "0.778": 10, "0.794": 10.5, "0.810": 11, "0.826": 11.5, "0.842": 12],
        .cm: ["4.42": 3, "4.55": 3.5, "4.68": 4, "4.80": 4.5, "4.93": 5, "5.06": 5.5, "5.19": 6, "5.31": 6.5, "5.44": 7, "5.57": 7.5, "5.70": 8, "5.82": 8.5, "5.95": 9, "6.08": 9.5, "6.21": 10, "6.33": 10.5, "6.46": 11, "6.59": 11.5, "6.72": 12]
    ]
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        return convertWithDetails(size: size, from: from, to: to, gender: gender, type: .ring).convertedSize
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        guard let fromTable = conversions[from],
              let toTable = conversions[to],
              let usSize = fromTable[size.normalizedSize] else {
            return ConversionResult(
                originalSize: size,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                error: .invalidSize(size)
            )
        }
        
        if let targetSize = toTable.sizeKey(matching: usSize, preferring: size.normalizedSize) {
            return ConversionResult(
                originalSize: size,
                convertedSize: targetSize,
                fromSystem: from,
                toSystem: to,
                type: type,
                gender: gender,
                confidence: 0.98,
                notes: "Ring sizing is based on internal circumference"
            )
        }
        
        return ConversionResult(
            originalSize: size,
            fromSystem: from,
            toSystem: to,
            type: type,
            gender: gender,
            error: .sizeOutOfRange(size, validRange: "3-12")
        )
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        return conversions[system]?.keys.contains(size.normalizedSize) == true
    }
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["6", "6.5", "7", "7.5", "8"]
    }
}
