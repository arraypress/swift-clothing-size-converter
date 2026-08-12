//
//  BeltConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Converter for belt / waist sizes.
///
/// Every system is resolved to a waist measurement in **inches** and then
/// formatted for the target, so any pair of systems converts through a single
/// pivot rather than a hand-written table of special cases:
/// - **US / UK / inches** — the value is the waist in inches (32, 34, 36…).
/// - **EU** — inch waist plus 16 (US 34 → EU 50).
/// - **cm** — the waist in centimetres (inches × 2.54).
internal struct BeltConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu, .cm, .inches] }

    /// Number of sizes an EU belt label sits above the US inch waist.
    private let euOffset = 16.0

    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        guard let inches = waistInches(of: size, in: from) else { return nil }
        return format(inches: inches, for: to)
    }

    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 0.9)
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }

    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        // Validate against a plausible waist range (≈20"–60") in whatever unit
        // the system uses, rather than a fixed inch range that rejected every
        // cm or EU belt size.
        guard let inches = waistInches(of: size, in: system) else { return false }
        return inches >= 20 && inches <= 60
    }

    /// Sizes this system actually uses, derived rather than listed.
    ///
    /// The anchors below are US sizes. Any other system's suggestions come
    /// from running them through this converter, so they cannot contradict
    /// what `convert` will accept — the previous hardcoded list was US
    /// numbers offered as the answer for every system.
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        guard system != .us else { return ["30", "32", "34", "36", "38", "40"] }
        return ["30", "32", "34", "36", "38", "40"].compactMap {
            convert(size: $0, from: .us, to: system, gender: gender)
        }
    }

    // MARK: - Private

    /// The waist in inches for a size expressed in the given system.
    private func waistInches(of size: String, in system: SizeSystem) -> Double? {
        let cleaned = size.normalizedSize
            .replacingOccurrences(of: "CM", with: "")
            .replacingOccurrences(of: "IN", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard let value = Double(cleaned) else { return nil }
        switch system {
        case .eu:  return value - euOffset
        case .cm:  return value / 2.54
        default:   return value            // us / uk / inches
        }
    }

    /// Format an inch waist as a whole-number label in the target system.
    private func format(inches: Double, for system: SizeSystem) -> String {
        let value: Double
        switch system {
        case .eu:  value = inches + euOffset
        case .cm:  value = inches * 2.54
        default:   value = inches          // us / uk / inches
        }
        return String(Int(value.rounded()))
    }
}
