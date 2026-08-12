//
//  SockConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

/// Converter for sock sizes using shoe size logic
///
/// Socks typically follow the same sizing as shoes since they're based on foot size.
internal struct SockConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu] }
    
    func convert(size: String, from: SizeSystem, to: SizeSystem, gender: Gender) -> String? {
        let shoeConverter = ShoeConverter()
        return shoeConverter.convert(size: size, from: from, to: to, gender: gender)
    }
    
    func convertWithDetails(size: String, from: SizeSystem, to: SizeSystem, gender: Gender, type: SizeType) -> ConversionResult {
        let shoeConverter = ShoeConverter()
        return shoeConverter.convertWithDetails(size: size, from: from, to: to, gender: gender, type: type)
    }
    
    func isValid(size: String, system: SizeSystem, gender: Gender) -> Bool {
        let shoeConverter = ShoeConverter()
        return shoeConverter.isValid(size: size, system: system, gender: gender)
    }
    
    /// Sizes this system actually uses, derived rather than listed.
    ///
    /// The anchors below are US sizes. Any other system's suggestions come
    /// from running them through this converter, so they cannot contradict
    /// what `convert` will accept — the previous hardcoded list was US
    /// numbers offered as the answer for every system.
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        guard system != .us else { return ["6", "7", "8", "9", "10", "11", "12"] }
        return ["6", "7", "8", "9", "10", "11", "12"].compactMap {
            convert(size: $0, from: .us, to: system, gender: gender)
        }
    }
}