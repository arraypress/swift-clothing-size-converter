//
//  SizePatterns.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


internal struct SizePatterns: Sendable {
    /// Common shoe size patterns
    static let shoeSize = #"^\d+(\.\d+)?$"#
    
    /// Clothing size patterns
    static let letterSize = #"^(XXS|XS|S|M|L|XL|XXL|XXXL)$"#
    static let numericSize = #"^\d+$"#
    static let plusSize = #"^\d*X{1,3}$"#
    
    /// Bra size patterns
    static let braSize = #"^\d{2,3}[A-K]+$"#
    
    /// Ring size patterns
    static let ringNumeric = #"^\d+(\.\d+)?$"#
    static let ringLetter = #"^[A-Z]$"#
    
    /// Hat size patterns
    static let hatFraction = #"^\d+(\s*\d+/\d+)?$"#
    static let hatNumeric = #"^\d+(\.\d+)?$"#
    
    /// Belt/waist size patterns
    static let waistSize = #"^\d{2,3}$"#
    
    /// Watch size patterns
    static let watchSize = #"^\d{2,3}(mm)?$"#
    
    /// Children's size patterns
    static let infantSize = #"^\d{1,2}M$"#
    static let toddlerSize = #"^\d{1}T$"#
    static let childrenSize = #"^\d{1,2}$"#
    static let youthSize = #"^(XS|S|M|L|XL)$"#
    
    /// Swimwear size patterns
    static let swimwearSize = #"^(\d{2,3}[A-K]+|XXS|XS|S|M|L|XL|XXL|\d+)$"#
}