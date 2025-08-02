//
//  SockConverter.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


/// Converter for sock sizes using shoe size logic
///
/// Socks typically follow the same sizing as shoes since they're based on foot size.
internal struct SockConverter: SizeConverterProtocol {
    var supportedSystems: [SizeSystem] { [.us, .uk, .eu] }
    var requiresGender: Bool { false }
    
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
    
    func getSuggestions(for size: String, system: SizeSystem, gender: Gender) -> [String] {
        return ["6", "7", "8", "9", "10", "11", "12"]
    }
}