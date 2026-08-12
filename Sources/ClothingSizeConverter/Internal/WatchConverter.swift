//
//  WatchConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Converter for watch case sizes.
///
/// Watch cases are quoted by their diameter, which is effectively universal:
/// US and EU both label it in millimetres (38, 40, 42…), while the `cm` system
/// expresses the same diameter in centimetres (3.8, 4.0, 4.2…). Conversion is
/// therefore a straight unit change through millimetres, and an optional `mm`
/// suffix on the input is accepted.
internal struct WatchConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .eu, .cm] }

    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        guard let mm = millimeters(of: size, in: from) else { return nil }
        return format(millimeters: mm, for: to)
    }

    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        if let converted = convert(size: size, from: from, to: to, gender: gender) {
            return ConversionResult(originalSize: size, convertedSize: converted, fromSystem: from, toSystem: to, type: type, gender: gender, confidence: 1.0, notes: "Watch cases are sized by diameter")
        }
        return ConversionResult(originalSize: size, fromSystem: from, toSystem: to, type: type, gender: gender, error: .invalidSize(size))
    }

    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        guard let mm = millimeters(of: size, in: system) else { return false }
        return mm >= 20 && mm <= 60
    }

    /// Sizes this system actually uses, derived rather than listed.
    ///
    /// The anchors below are US sizes. Any other system's suggestions come
    /// from running them through this converter, so they cannot contradict
    /// what `convert` will accept — the previous hardcoded list was US
    /// numbers offered as the answer for every system.
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        guard system != .us else { return ["38", "40", "42", "44", "46"] }
        return ["38", "40", "42", "44", "46"].compactMap {
            convert(size: $0, from: .us, to: system, gender: gender)
        }
    }

    // MARK: - Private

    /// The case diameter in millimetres, parsed from a size in the given system.
    ///
    /// `mm` suffixes are stripped; a `cm` system value (e.g. "4.2") is scaled up
    /// by ten, everything else is taken as millimetres.
    private func millimeters(of size: String, in system: SizeSystem) -> Double? {
        let cleaned = size.normalizedSize
            .replacingOccurrences(of: "MM", with: "")
            .replacingOccurrences(of: "CM", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard let value = Double(cleaned) else { return nil }
        return system == .cm ? value * 10 : value
    }

    /// Format a millimetre diameter for the target system (cm as centimetres,
    /// otherwise whole millimetres), dropping any trailing `.0`.
    private func format(millimeters mm: Double, for system: SizeSystem) -> String {
        let value = system == .cm ? mm / 10 : mm
        return String(format: "%g", value)
    }
}
