//
//  ConversionError.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Errors that can occur during size conversion.
public enum ConversionError: Error, LocalizedError, Equatable, Sendable {
    /// The input couldn't be parsed as a size for the given system/type.
    case invalidSize(String)
    /// No converter exists for the requested size type.
    case unsupportedType(SizeType)
    /// The sizing system isn't supported for this size type.
    case unsupportedSystem(SizeSystem, for: SizeType)
    /// The input parsed, but sits outside the supported range for the system.
    case sizeOutOfRange(String, validRange: String)
    /// The input didn't match the expected format for this size type.
    case invalidFormat(String, expectedFormat: String)

    public var errorDescription: String? {
        switch self {
        case .invalidSize(let size):
            return "Invalid size format: '\(size)'"
        case .unsupportedType(let type):
            return "Unsupported size type: \(type.rawValue)"
        case .unsupportedSystem(let system, let type):
            return "\(system.rawValue) sizing not supported for \(type.rawValue)"
        case .sizeOutOfRange(let size, let range):
            return "Size '\(size)' out of valid range: \(range)"
        case .invalidFormat(let size, let expectedFormat):
            return "Invalid format '\(size)'. Expected: \(expectedFormat)"
        }
    }

    /// User-friendly error message.
    public var userFriendlyDescription: String {
        switch self {
        case .invalidSize(let size):
            return "'\(size)' is not a valid size"
        case .unsupportedType(let type):
            return "\(type.description) conversion not supported"
        case .unsupportedSystem(let system, let type):
            return "\(system.fullName) sizes not available for \(type.description.lowercased())"
        case .sizeOutOfRange(let size, let range):
            return "Size '\(size)' not found. Available: \(range)"
        case .invalidFormat(_, let expectedFormat):
            return "Invalid format. Example: \(expectedFormat)"
        }
    }
}
