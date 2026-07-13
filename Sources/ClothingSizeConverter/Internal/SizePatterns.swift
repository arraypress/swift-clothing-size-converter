//
//  SizePatterns.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

/// Regular-expression patterns used to validate size formats.
internal struct SizePatterns: Sendable {
    /// A whole or half/decimal number, e.g. "9", "9.5", "42" — used to validate
    /// shoe sizes before a table lookup.
    static let shoeSize = #"^\d+(\.\d+)?$"#

    /// Youth letter sizes (XS–XL), used to steer children's suggestions.
    static let youthSize = #"^(XS|S|M|L|XL)$"#
}
