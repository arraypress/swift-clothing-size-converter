//
//  AuditRegressionTests.swift
//  ClothingSizeConverter
//
//  Regression tests for the correctness issues found during the audit.
//  Each test pins down a specific bug so it can't quietly come back.
//
//  Created by David Sherlock on 2026.
//

import XCTest
@testable import ClothingSizeConverter

final class AuditRegressionTests: XCTestCase {

    // MARK: - Deterministic reverse lookup

    /// Several US clothing keys share a normalized value ("XXL", "1X" and "42"
    /// are all men's chest 42; "M" and "8" are both women's 8). A plain
    /// dictionary-iteration reverse lookup could return any of them and varied
    /// between runs. The result must now be stable and prefer the numeric form.
    func testClothingToUSIsDeterministicAndNumeric() {
        // Women: EU 40 → US 8 (numeric, not "M").
        for _ in 0..<25 {
            XCTAssertEqual(
                ClothingSizeConverter.convert("40", from: .eu, to: .us, type: .clothing, gender: .women),
                "8"
            )
        }
        // Men: EU 54 → US 44 (numeric, not "XXXL"/"2X"); EU 50 → US 40.
        XCTAssertEqual(ClothingSizeConverter.convert("54", from: .eu, to: .us, type: .clothing, gender: .men), "44")
        XCTAssertEqual(ClothingSizeConverter.convert("50", from: .eu, to: .us, type: .clothing, gender: .men), "40")
    }

    /// Swimwear women's US table also has value collisions ("S"/"34A"/"34B" = 4).
    /// The conversion must be stable across repeated calls.
    func testSwimwearToUSIsStable() {
        let first = ClothingSizeConverter.convert("8", from: .uk, to: .us, type: .swimwear, gender: .women)
        XCTAssertNotNil(first)
        for _ in 0..<25 {
            XCTAssertEqual(
                ClothingSizeConverter.convert("8", from: .uk, to: .us, type: .swimwear, gender: .women),
                first
            )
        }
    }

    /// Round-tripping a numeric clothing size through EU must return the original.
    func testClothingRoundTripThroughEU() {
        for (size, gender) in [("8", Gender.women), ("12", .women), ("38", .men), ("44", .men)] {
            let eu = ClothingSizeConverter.convert(size, from: .us, to: .eu, type: .clothing, gender: gender)
            XCTAssertNotNil(eu, "US \(size) → EU should succeed")
            let back = eu.flatMap { ClothingSizeConverter.convert($0, from: .eu, to: .us, type: .clothing, gender: gender) }
            XCTAssertEqual(back, size, "US \(size) → EU → US should round-trip")
        }
    }

    // MARK: - Non-US children's routing

    /// The children's converter used to pick its table by pattern-matching the
    /// input, which assumed US formats — so European/UK/French children's sizes
    /// silently failed. Table selection is now driven by the gender.
    func testChildrensConvertFromNonUSSystems() {
        // EU height → US, per age group.
        XCTAssertEqual(ClothingSizeConverter.convert("62", from: .eu, to: .us, type: .clothing, gender: .infant), "6M")
        XCTAssertEqual(ClothingSizeConverter.convert("92", from: .eu, to: .us, type: .clothing, gender: .toddler), "2T")
        XCTAssertEqual(ClothingSizeConverter.convert("104", from: .eu, to: .us, type: .clothing, gender: .children), "4")
        XCTAssertEqual(ClothingSizeConverter.convert("152", from: .eu, to: .us, type: .clothing, gender: .children), "12")
        XCTAssertEqual(ClothingSizeConverter.convert("140", from: .eu, to: .us, type: .clothing, gender: .youth), "M")

        // UK / FR sources too.
        XCTAssertEqual(ClothingSizeConverter.convert("3", from: .uk, to: .us, type: .clothing, gender: .toddler), "3T")
        XCTAssertEqual(ClothingSizeConverter.convert("8A", from: .fr, to: .us, type: .clothing, gender: .children), "8")
    }

    /// Gender disambiguates numbers that exist in more than one age table
    /// (e.g. UK "4" is both a toddler and a children's size).
    func testChildrensGenderDisambiguatesSharedNumbers() {
        XCTAssertEqual(ClothingSizeConverter.convert("4", from: .uk, to: .eu, type: .clothing, gender: .toddler), "104")
        XCTAssertEqual(ClothingSizeConverter.convert("4", from: .uk, to: .eu, type: .clothing, gender: .children), "104")
    }

    func testChildrensRoundTrip() {
        for (size, gender) in [("6M", Gender.infant), ("3T", .toddler), ("8", .children), ("S", .youth)] {
            let eu = ClothingSizeConverter.convert(size, from: .us, to: .eu, type: .clothing, gender: gender)
            let back = eu.flatMap { ClothingSizeConverter.convert($0, from: .eu, to: .us, type: .clothing, gender: gender) }
            XCTAssertEqual(back, size, "\(size) should round-trip US→EU→US")
        }
    }

    // MARK: - Watch cm conversions

    /// Watch conversions used to short-circuit on any integer, so the `cm`
    /// system never worked and the source system was ignored.
    func testWatchMillimetreCentimetreConversion() {
        XCTAssertEqual(ClothingSizeConverter.convert("42", from: .us, to: .cm, type: .watch), "4.2")
        XCTAssertEqual(ClothingSizeConverter.convert("4.2", from: .cm, to: .us, type: .watch), "42")
        XCTAssertEqual(ClothingSizeConverter.convert("40mm", from: .us, to: .cm, type: .watch), "4")
        // Millimetre systems remain identity.
        XCTAssertEqual(ClothingSizeConverter.convert("42", from: .us, to: .eu, type: .watch), "42")
    }

    // MARK: - Belt validation + metric conversions

    /// `isValid` used to hardcode an inch range (28–50) regardless of system,
    /// rejecting every valid centimetre or EU belt size.
    func testBeltValidationIsSystemAware() {
        XCTAssertTrue(ClothingSizeConverter.isValid("85", for: .belt, system: .cm))   // ≈ 33.5"
        XCTAssertTrue(ClothingSizeConverter.isValid("50", for: .belt, system: .eu))   // = 34"
        XCTAssertTrue(ClothingSizeConverter.isValid("34", for: .belt, system: .us))
        XCTAssertFalse(ClothingSizeConverter.isValid("10", for: .belt, system: .us))  // too small
    }

    /// Cross-system belt conversions now route through an inch pivot instead of
    /// silently returning the input unchanged.
    func testBeltCrossSystemConversions() {
        XCTAssertEqual(ClothingSizeConverter.convert("34", from: .us, to: .eu, type: .belt), "50")
        XCTAssertEqual(ClothingSizeConverter.convert("34", from: .us, to: .cm, type: .belt), "86")
        // Round-trip US→EU→US.
        let eu = ClothingSizeConverter.convert("36", from: .us, to: .eu, type: .belt)
        XCTAssertEqual(eu.flatMap { ClothingSizeConverter.convert($0, from: .eu, to: .us, type: .belt) }, "36")
        // cm source now converts rather than passing through.
        XCTAssertEqual(ClothingSizeConverter.convert("86", from: .cm, to: .us, type: .belt), "34")
    }

    // MARK: - isClothingSize

    /// The old `isClothingSize` used a broken character class `[XS|S|M|L|XL|XXL]`
    /// that accepted garbage like "|" or "LLLL". It must now accept real sizes
    /// and reject nonsense.
    func testIsClothingSizeAcceptsValidRejectsGarbage() {
        for valid in ["9.5", "42", "XL", "XXL", "1X", "2X", "34B", "36DD", "S", "m"] {
            XCTAssertTrue(valid.isClothingSize, "\(valid) should be a clothing size")
        }
        for garbage in ["|", "LLLL", "SMSM", "invalid123!", "", "X Y Z", "99Z9"] {
            XCTAssertFalse(garbage.isClothingSize, "\(garbage) should NOT be a clothing size")
        }
    }

    // MARK: - Men's clothing letter sizing

    /// The men's letter→chest anchors were undersized (M resolved to EU 48 as if
    /// it were an S). Re-anchored to XS=34, S=36, M=38, L=42, XL=46, XXL=50.
    func testMensClothingLetterAnchors() {
        XCTAssertEqual(ClothingSizeConverter.convert("S", from: .us, to: .eu, type: .clothing, gender: .men), "46")
        XCTAssertEqual(ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .clothing, gender: .men), "48")
        XCTAssertEqual(ClothingSizeConverter.convert("L", from: .us, to: .eu, type: .clothing, gender: .men), "52")
        XCTAssertEqual(ClothingSizeConverter.convert("XL", from: .us, to: .eu, type: .clothing, gender: .men), "56")
        XCTAssertEqual(ClothingSizeConverter.convert("XXL", from: .us, to: .eu, type: .clothing, gender: .men), "60")
        // Reverse still resolves to the numeric form, not a letter.
        XCTAssertEqual(ClothingSizeConverter.convert("52", from: .eu, to: .us, type: .clothing, gender: .men), "42")
    }

    // MARK: - Bra cup equivalences (large cups)

    /// The US cup ladder listed DDD and F as separate cups, but they're the same
    /// cup — so every F+ equivalence was off by one. These pin the corrected
    /// UK/EU cup mappings (US F = DDD; UK F = US G; UK FF = US H; EU G = US G).
    func testBraLargeCupEquivalences() {
        XCTAssertEqual(ClothingSizeConverter.convert("34F", from: .us, to: .uk, type: .bra), "34E")   // US F = DDD = UK E
        XCTAssertEqual(ClothingSizeConverter.convert("34G", from: .us, to: .uk, type: .bra), "34F")   // US G = UK F
        XCTAssertEqual(ClothingSizeConverter.convert("34F", from: .uk, to: .us, type: .bra), "34G")   // UK F = US G
        XCTAssertEqual(ClothingSizeConverter.convert("34FF", from: .uk, to: .us, type: .bra), "34H")  // UK FF = US H
        XCTAssertEqual(ClothingSizeConverter.convert("75G", from: .eu, to: .us, type: .bra), "34G")   // EU G = US G
        // The DDD/F alias canonicalizes to DDD on output, never the alias.
        XCTAssertEqual(ClothingSizeConverter.convert("34F", from: .us, to: .us, type: .bra), "34DDD")
        // Regression guard: the already-correct small cups still round-trip.
        XCTAssertEqual(ClothingSizeConverter.convert("34DD", from: .us, to: .uk, type: .bra), "34DD")
        XCTAssertEqual(ClothingSizeConverter.convert("34B", from: .us, to: .eu, type: .bra), "75B")
    }

    // MARK: - Ring metric columns

    /// The EU/JP/cm/inches ring columns used a wrong slope (~2 mm/size instead of
    /// ~2.55) and were mislabeled. These pin the ISO-8653 corrected values.
    func testRingMetricColumns() {
        XCTAssertEqual(ClothingSizeConverter.convert("7", from: .us, to: .eu, type: .ring), "54")     // was 52
        XCTAssertEqual(ClothingSizeConverter.convert("12", from: .us, to: .eu, type: .ring), "67")    // was 62
        XCTAssertEqual(ClothingSizeConverter.convert("7", from: .us, to: .cm, type: .ring), "5.44")   // was 4.98
        XCTAssertEqual(ClothingSizeConverter.convert("7", from: .us, to: .jp, type: .ring), "14")     // was 15
        XCTAssertEqual(ClothingSizeConverter.convert("7", from: .us, to: .uk, type: .ring), "N")      // unchanged
        // Round-trip through the corrected EU column.
        let eu = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .ring)
        XCTAssertEqual(eu.flatMap { ClothingSizeConverter.convert($0, from: .eu, to: .us, type: .ring) }, "9")
    }

    // MARK: - Shoe suggestions formatting

    /// Suggestions used to be built with `String(Double)`, producing "9.0" which
    /// never matches the "9" table keys. They must be formatted cleanly.
    func testShoeSuggestionsHaveNoTrailingZero() {
        let suggestions = ClothingSizeConverter.getSuggestions(for: "9", type: .shoe, system: .us, gender: .women)
        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertTrue(suggestions.contains("9"))
        for s in suggestions {
            XCTAssertFalse(s.hasSuffix(".0"), "Suggestion \(s) should not carry a trailing .0")
        }
    }
}
