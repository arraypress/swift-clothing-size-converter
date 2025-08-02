//
//  RemainingConverters.swift
//  ClothingSizeConverter
//
//  Ring, Hat, Glove, Belt, Sock, Watch, Children's, and Swimwear converters
//  Created on 28/07/2025.
//

import Foundation

// MARK: - Ring Converter

/// Converter for ring sizes across international systems
///
/// Supports conversion between US, UK, EU, JP, inches, and centimeter sizing systems.
/// Ring sizing is based on the internal circumference or diameter of the ring.
///
/// ## Supported Systems
/// - **US**: Numeric sizes 3-12 (standard US ring sizing)
/// - **UK**: Letter sizes F-X (British alphabetical system)
/// - **EU**: Numeric sizes 44-62 (European millimeter circumference)
/// - **JP**: Numeric sizes 3-25 (Japanese sizing system)
/// - **Inches**: Decimal measurements 1.833-2.118 (internal diameter)
/// - **CM**: Decimal measurements 4.65-5.37 (internal circumference)
///
/// ## Example Usage
/// ```swift
/// let converter = RingConverter()
///
/// // Convert US size 7 to UK
/// let result = converter.convert(size: "7", from: .us, to: .uk, gender: .unisex)
/// // Result: "N"
///
/// // Convert to metric measurements
/// let cmResult = converter.convert(size: "7", from: .us, to: .cm, gender: .unisex)
/// // Result: "4.98"
/// ```
internal struct RingConverter: SizeConverterProtocol {
    
    var supportedSystems: [SizeSystem] {
        return [.us, .uk, .eu, .jp, .inches, .cm]
    }
    
    var requiresGender: Bool {
        return false
    }
    
    /// Ring size conversion table mapping all systems to normalized US sizes
    private let conversions: [SizeSystem: [String: Double]] = [
        .us: ["3": 3, "3.5": 3.5, "4": 4, "4.5": 4.5, "5": 5, "5.5": 5.5, "6": 6, "6.5": 6.5, "7": 7, "7.5": 7.5, "8": 8, "8.5": 8.5, "9": 9, "9.5": 9.5, "10": 10, "10.5": 10.5, "11": 11, "11.5": 11.5, "12": 12],
        .uk: ["F": 3, "G": 3.5, "H": 4, "I": 4.5, "J": 5, "K": 5.5, "L": 6, "M": 6.5, "N": 7, "O": 7.5, "P": 8, "Q": 8.5, "R": 9, "S": 9.5, "T": 10, "U": 10.5, "V": 11, "W": 11.5, "X": 12],
        .eu: ["44": 3, "45": 3.5, "46": 4, "47": 4.5, "48": 5, "49": 5.5, "50": 6, "51": 6.5, "52": 7, "53": 7.5, "54": 8, "55": 8.5, "56": 9, "57": 9.5, "58": 10, "59": 10.5, "60": 11, "61": 11.5, "62": 12],
        .jp: ["3": 3, "5": 3.5, "7": 4, "8": 4.5, "9": 5, "11": 5.5, "13": 6, "14": 6.5, "15": 7, "16": 7.5, "17": 8, "18": 8.5, "19": 9, "20": 9.5, "21": 10, "22": 10.5, "23": 11, "24": 11.5, "25": 12],
        .inches: ["1.833": 3, "1.849": 3.5, "1.865": 4, "1.881": 4.5, "1.896": 5, "1.912": 5.5, "1.928": 6, "1.944": 6.5, "1.960": 7, "1.976": 7.5, "1.991": 8, "2.007": 8.5, "2.023": 9, "2.039": 9.5, "2.055": 10, "2.071": 10.5, "2.086": 11, "2.102": 11.5, "2.118": 12],
        .cm: ["4.65": 3, "4.70": 3.5, "4.74": 4, "4.78": 4.5, "4.82": 5, "4.86": 5.5, "4.90": 6, "4.94": 6.5, "4.98": 7, "5.02": 7.5, "5.05": 8, "5.09": 8.5, "5.13": 9, "5.17": 9.5, "5.21": 10, "5.25": 10.5, "5.29": 11, "5.33": 11.5, "5.37": 12]
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
        
        for (targetSize, targetUSSize) in toTable {
            if abs(targetUSSize - usSize) < 0.01 {
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
