//
//  SizeSystem.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//


/// International sizing systems
public enum SizeSystem: String, CaseIterable, Sendable {
    case us = "US"
    case uk = "UK"
    case eu = "EU"
    case fr = "FR"
    case it = "IT"
    case jp = "JP"
    case au = "AU"
    case cn = "CN"
    case kr = "KR"
    case cm = "CM"
    case inches = "IN"
    
    /// Full country/region name
    public var fullName: String {
        switch self {
        case .us: return "United States"
        case .uk: return "United Kingdom"
        case .eu: return "European Union"
        case .fr: return "France"
        case .it: return "Italy"
        case .jp: return "Japan"
        case .au: return "Australia"
        case .cn: return "China"
        case .kr: return "South Korea"
        case .cm: return "Centimeters"
        case .inches: return "Inches"
        }
    }
    
    /// Whether this is a measurement-based system
    public var isMeasurement: Bool {
        return [.cm, .inches].contains(self)
    }
}