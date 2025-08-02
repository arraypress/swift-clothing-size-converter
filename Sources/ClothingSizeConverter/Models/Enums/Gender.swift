//
//  Gender.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 02/08/2025.
//

import Foundation

/// Gender context for sizing
public enum Gender: String, CaseIterable, Sendable {
    case men = "men"
    case women = "women"
    case unisex = "unisex"
    case children = "children"
    case infant = "infant"
    case toddler = "toddler"
    case youth = "youth"
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .men: return "Men's"
        case .women: return "Women's"
        case .unisex: return "Unisex"
        case .children: return "Children's"
        case .infant: return "Infant"
        case .toddler: return "Toddler"
        case .youth: return "Youth"
        }
    }
    
    /// Whether this is a children's category
    public var isChildrens: Bool {
        return [.children, .infant, .toddler, .youth].contains(self)
    }
}
