//
//  ClothingSizeConverterTests.swift
//  ClothingSizeConverter
//
//  Comprehensive test suite for clothing size conversion
//  Created on 02/08/2025.
//

import XCTest
@testable import ClothingSizeConverter

final class ClothingSizeConverterTests: XCTestCase {
    
    // MARK: - Basic Shoe Conversion Tests
    
    func testBasicShoeConversion() {
        // US to EU women's shoes
        let result = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .women)
        XCTAssertEqual(result, "39", "US Women's 9 should convert to EU 39")
        
        // EU to US men's shoes
        let menResult = ClothingSizeConverter.convert("42", from: .eu, to: .us, type: .shoe, gender: .men)
        XCTAssertEqual(menResult, "8.5", "EU Men's 42 should convert to US 8.5")
    }
    
    func testSameSystemConversion() {
        let result = ClothingSizeConverter.convert("9.5", from: .us, to: .us, type: .shoe, gender: .women)
        XCTAssertEqual(result, "9.5", "Same system conversion should return normalized input")
    }
    
    func testInvalidSizeHandling() {
        // Test with shoe converter (original test)
        let shoeResult = ClothingSizeConverter.convert("invalid", from: .us, to: .eu, type: .shoe, gender: .women)
        XCTAssertNil(shoeResult, "Invalid size should return nil")
        
        // Test with detailed conversion for clothing
        let clothingResult = ClothingSizeConverter.convertWithDetails(
            "invalid",
            from: .us,
            to: .eu,
            type: .clothing,
            gender: .women
        )
        
        XCTAssertFalse(clothingResult.isSuccess, "Invalid size conversion should fail")
        XCTAssertNotNil(clothingResult.error, "Should provide error information")
        XCTAssertNil(clothingResult.convertedSize, "Should not return converted size for invalid input")
        
        // Test with a clearly invalid size for shoes
        let detailedShoeResult = ClothingSizeConverter.convertWithDetails(
            "999",
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        XCTAssertFalse(detailedShoeResult.isSuccess, "Invalid shoe size should fail")
        XCTAssertNotNil(detailedShoeResult.error, "Should provide error for invalid shoe size")
    }
    
    // MARK: - Detailed Conversion Tests
    
    func testDetailedConversionSuccess() {
        let result = ClothingSizeConverter.convertWithDetails(
            "9.5",
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        XCTAssertTrue(result.isSuccess, "Conversion should succeed")
        XCTAssertEqual(result.convertedSize, "39.5", "US Women's 9.5 should convert to EU 39.5")
        XCTAssertEqual(result.originalSize, "9.5")
        XCTAssertEqual(result.fromSystem, .us)
        XCTAssertEqual(result.toSystem, .eu)
        XCTAssertEqual(result.type, .shoe)
        XCTAssertEqual(result.gender, .women)
        XCTAssertGreaterThan(result.confidence, 0.8, "High confidence expected for standard conversion")
        XCTAssertNil(result.error, "No error expected for valid conversion")
    }
    
    func testDetailedConversionFailure() {
        let result = ClothingSizeConverter.convertWithDetails(
            "999",
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        XCTAssertFalse(result.isSuccess, "Invalid size conversion should fail")
        XCTAssertNil(result.convertedSize, "Should not return converted size for invalid input")
        XCTAssertNotNil(result.error, "Should provide error information")
    }
    
    // MARK: - Multiple Conversion Tests
    
    func testMultipleConversions() {
        let sizes = ["8", "9", "10", "invalid", "11"]
        let results = ClothingSizeConverter.convertMultiple(
            sizes,
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        XCTAssertEqual(results.count, 5, "Should return same number of results as input")
        XCTAssertEqual(results[0], "38", "US 8 → EU 38")
        XCTAssertEqual(results[1], "39", "US 9 → EU 39")
        XCTAssertEqual(results[2], "40", "US 10 → EU 40")
        XCTAssertNil(results[3], "Invalid size should return nil")
        XCTAssertEqual(results[4], "41", "US 11 → EU 41")
    }
    
    func testMultipleConversionsLimitClamping() {
        let manySizes = Array(repeating: "9", count: 150)
        let results = ClothingSizeConverter.convertMultiple(
            manySizes,
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        XCTAssertEqual(results.count, 100, "Should clamp to maximum of 100 conversions")
    }
    
    // MARK: - Validation Tests
    
    func testSizeValidation() {
        // Valid sizes
        XCTAssertTrue(ClothingSizeConverter.isValid("9.5", for: .shoe, system: .us, gender: .women))
        XCTAssertTrue(ClothingSizeConverter.isValid("42", for: .shoe, system: .eu, gender: .men))
        XCTAssertTrue(ClothingSizeConverter.isValid("7", for: .shoe, system: .uk, gender: .women))
        
        // Invalid sizes
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .shoe, system: .us, gender: .women))
        XCTAssertFalse(ClothingSizeConverter.isValid("999", for: .shoe, system: .us, gender: .women))
        XCTAssertFalse(ClothingSizeConverter.isValid("", for: .shoe, system: .us, gender: .women))
    }
    
    func testSizeSuggestions() {
        let suggestions = ClothingSizeConverter.getSuggestions(
            for: "9 1/2",
            type: .shoe,
            system: .us,
            gender: .women
        )
        
        XCTAssertTrue(suggestions.contains("9.5"), "Should suggest decimal equivalent for fraction")
        XCTAssertFalse(suggestions.isEmpty, "Should provide suggestions for correctable input")
    }
    
    // MARK: - Gender-Specific Tests
    
    func testGenderDifferences() {
        // Men's and women's shoe sizes are different
        let menResult = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .men)
        let womenResult = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .women)
        
        XCTAssertNotEqual(menResult, womenResult, "Men's and women's conversions should differ")
        XCTAssertEqual(menResult, "42.5", "US Men's 9 should convert to EU 42.5")
        XCTAssertEqual(womenResult, "39", "US Women's 9 should convert to EU 39")
    }
    
    func testUnisexDefaultsToMen() {
        let unisexResult = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .unisex)
        let menResult = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .men)
        
        XCTAssertEqual(unisexResult, menResult, "Unisex should use men's sizing for shoes")
    }
    
    // MARK: - Round-Trip Conversion Tests
    
    func testRoundTripConversions() {
        let originalSizes = ["8", "9.5", "10", "11.5"]
        
        for originalSize in originalSizes {
            // Convert US → EU → US
            if let euSize = ClothingSizeConverter.convert(originalSize, from: .us, to: .eu, type: .shoe, gender: .women),
               let backToUS = ClothingSizeConverter.convert(euSize, from: .eu, to: .us, type: .shoe, gender: .women) {
                
                XCTAssertEqual(backToUS, originalSize, "Round-trip conversion US→EU→US should preserve original size for \(originalSize)")
            } else {
                XCTFail("Round-trip conversion failed for size \(originalSize)")
            }
        }
    }
    
    // MARK: - Extended Size Range Tests
    
    func testExtendedSizes() {
        // Test very small sizes
        let smallResult = ClothingSizeConverter.convertWithDetails(
            "4",
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        XCTAssertTrue(smallResult.isSuccess, "Should handle small sizes")
        XCTAssertEqual(smallResult.convertedSize, "34", "US Women's 4 should convert to EU 34")
        
        // Test large sizes (might be extrapolated)
        let largeResult = ClothingSizeConverter.convertWithDetails(
            "15",
            from: .us,
            to: .eu,
            type: .shoe,
            gender: .women
        )
        
        if largeResult.isSuccess {
            XCTAssertLessThan(largeResult.confidence, 0.9, "Large sizes should have lower confidence")
        }
    }
    
    // MARK: - Clothing Converter Tests
    
    func testClothingConversion() {
        // Women's clothing US to EU
        let womenResult = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .clothing, gender: .women)
        XCTAssertEqual(womenResult, "40", "US Women's 8 should convert to EU 40")
        
        // Men's clothing US to EU (numeric)
        let menResult = ClothingSizeConverter.convert("38", from: .us, to: .eu, type: .clothing, gender: .men)
        XCTAssertEqual(menResult, "48", "US Men's 38 should convert to EU 48")
        
        // Letter size conversion - M maps to US 36, which maps to EU 46
        let letterResult = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .clothing, gender: .men)
        XCTAssertEqual(letterResult, "46", "US Men's M should convert to EU 46")
    }
    
    func testClothingValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("M", for: .clothing, system: .us, gender: .men))
        XCTAssertTrue(ClothingSizeConverter.isValid("8", for: .clothing, system: .us, gender: .women))
        XCTAssertFalse(ClothingSizeConverter.isValid("999", for: .clothing, system: .us, gender: .women))
    }
    
    // MARK: - Bra Converter Tests
    
    func testBraConversion() {
        // US to UK bra size
        let result = ClothingSizeConverter.convert("34B", from: .us, to: .uk, type: .bra)
        XCTAssertEqual(result, "34B", "US 34B should convert to UK 34B (same)")
        
        // US to EU bra size
        let euResult = ClothingSizeConverter.convert("34B", from: .us, to: .eu, type: .bra)
        XCTAssertEqual(euResult, "75B", "US 34B should convert to EU 75B")
        
        // Cup size differences
        let cupResult = ClothingSizeConverter.convert("34DD", from: .us, to: .uk, type: .bra)
        XCTAssertEqual(cupResult, "34DD", "US 34DD should convert to UK 34DD")
    }
    
    func testBraValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("34B", for: .bra, system: .us))
        XCTAssertTrue(ClothingSizeConverter.isValid("36DD", for: .bra, system: .us))
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .bra, system: .us))
        XCTAssertFalse(ClothingSizeConverter.isValid("99Z", for: .bra, system: .us))
    }
    
    func testBraDetailedConversion() {
        let result = ClothingSizeConverter.convertWithDetails(
            "36C",
            from: .us,
            to: .eu,
            type: .bra
        )
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(result.convertedSize, "80C")
        XCTAssertEqual(result.gender, .women)
        XCTAssertGreaterThan(result.confidence, 0.9)
    }
    
    // MARK: - Ring Converter Tests
    
    func testRingConversion() {
        // US to UK ring size
        let result = ClothingSizeConverter.convert("7", from: .us, to: .uk, type: .ring)
        XCTAssertEqual(result, "N", "US ring size 7 should convert to UK N")
        
        // US to EU ring size
        let euResult = ClothingSizeConverter.convert("6.5", from: .us, to: .eu, type: .ring)
        XCTAssertEqual(euResult, "51", "US ring size 6.5 should convert to EU 51")
        
        // Metric conversions
        let cmResult = ClothingSizeConverter.convert("7", from: .us, to: .cm, type: .ring)
        XCTAssertEqual(cmResult, "4.98", "US ring size 7 should convert to 4.98cm")
    }
    
    func testRingValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("7", for: .ring, system: .us))
        XCTAssertTrue(ClothingSizeConverter.isValid("N", for: .ring, system: .uk))
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .ring, system: .us))
    }
    
    // MARK: - Hat Converter Tests
    
    func testHatConversion() {
        // US to EU hat size
        let result = ClothingSizeConverter.convert("7", from: .us, to: .eu, type: .hat)
        XCTAssertEqual(result, "56", "US hat size 7 should convert to EU 56")
        
        // Fractional size (should be normalized first)
        let suggestions = ClothingSizeConverter.getSuggestions(for: "7 1/8", type: .hat, system: .us)
        XCTAssertTrue(suggestions.contains("7.125"))
    }
    
    func testHatValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("7", for: .hat, system: .us))
        XCTAssertTrue(ClothingSizeConverter.isValid("56", for: .hat, system: .eu))
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .hat, system: .us))
    }
    
    // MARK: - Simple Converter Tests
    
    func testGloveConversion() {
        let result = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .glove)
        XCTAssertEqual(result, "M", "Glove sizes often use universal sizing")
        
        let numericResult = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .glove)
        XCTAssertEqual(numericResult, "M", "US glove size 8 should convert to M")
    }
    
    func testBeltConversion() {
        let result = ClothingSizeConverter.convert("34", from: .us, to: .eu, type: .belt)
        XCTAssertEqual(result, "50", "US belt size 34 should convert to EU 50 (add 16)")
        
        let cmResult = ClothingSizeConverter.convert("34", from: .us, to: .cm, type: .belt)
        XCTAssertEqual(cmResult, "86", "US belt size 34 should convert to 86cm")
    }
    
    func testSockConversion() {
        // Socks use shoe sizing, so should work like shoes
        let result = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .sock, gender: .men)
        XCTAssertEqual(result, "42.5", "US men's sock size 9 should convert like shoes")
    }
    
    func testWatchConversion() {
        let result = ClothingSizeConverter.convert("42", from: .us, to: .eu, type: .watch)
        XCTAssertEqual(result, "42", "Watch sizes are typically universal")
        
        let mmResult = ClothingSizeConverter.convert("42mm", from: .us, to: .eu, type: .watch)
        XCTAssertEqual(mmResult, "42", "Should handle mm suffix by removing it")
    }
    
    // MARK: - Children's Size Tests
    
    func testInfantSizes() {
        // Infant sizes (months)
        let result = ClothingSizeConverter.convert("12M", from: .us, to: .eu, type: .clothing, gender: .infant)
        XCTAssertEqual(result, "74", "US 12M should convert to EU 74")
        
        let detailedResult = ClothingSizeConverter.convertWithDetails("6M", from: .us, to: .eu, type: .clothing, gender: .infant)
        XCTAssertTrue(detailedResult.isSuccess)
        XCTAssertEqual(detailedResult.convertedSize, "62")
        XCTAssertTrue(detailedResult.notes?.contains("age") == true)
    }
    
    func testToddlerSizes() {
        // Toddler sizes (T sizes)
        let result = ClothingSizeConverter.convert("3T", from: .us, to: .eu, type: .clothing, gender: .toddler)
        XCTAssertEqual(result, "98", "US 3T should convert to EU 98")
        
        let ukResult = ClothingSizeConverter.convert("4T", from: .us, to: .uk, type: .clothing, gender: .toddler)
        XCTAssertEqual(ukResult, "4", "US 4T should convert to UK 4")
    }
    
    func testChildrenSizes() {
        // Regular children's numeric sizes
        let result = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .clothing, gender: .children)
        XCTAssertEqual(result, "128", "US children's 8 should convert to EU 128")
        
        let detailedResult = ClothingSizeConverter.convertWithDetails("12", from: .us, to: .eu, type: .clothing, gender: .children)
        XCTAssertTrue(detailedResult.isSuccess)
        XCTAssertEqual(detailedResult.convertedSize, "152")
    }
    
    func testYouthSizes() {
        // Youth letter sizes
        let result = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .clothing, gender: .youth)
        XCTAssertEqual(result, "140", "US youth M should convert to EU 140")
        
        let smallResult = ClothingSizeConverter.convert("S", from: .us, to: .eu, type: .clothing, gender: .youth)
        XCTAssertEqual(smallResult, "128", "US youth S should convert to EU 128")
    }
    
    func testChildrenValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("6M", for: .clothing, system: .us, gender: .infant))
        XCTAssertTrue(ClothingSizeConverter.isValid("3T", for: .clothing, system: .us, gender: .toddler))
        XCTAssertTrue(ClothingSizeConverter.isValid("8", for: .clothing, system: .us, gender: .children))
        XCTAssertTrue(ClothingSizeConverter.isValid("S", for: .clothing, system: .us, gender: .youth))
        
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .clothing, system: .us, gender: .infant))
    }
    
    // MARK: - Swimwear Tests
    
    func testWomensSwimwear() {
        // Women's swimwear letter sizes
        let result = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .swimwear, gender: .women)
        XCTAssertEqual(result, "36", "US women's swimwear M should convert to EU 36")
        
        // Women's swimwear with cup sizes - should convert based on normalized US size
        let cupResult = ClothingSizeConverter.convert("34B", from: .us, to: .uk, type: .swimwear, gender: .women)
        XCTAssertEqual(cupResult, "8", "US 34B swimwear should convert to UK 8")
        
        let detailedResult = ClothingSizeConverter.convertWithDetails("S", from: .us, to: .eu, type: .swimwear, gender: .women)
        XCTAssertTrue(detailedResult.isSuccess)
        XCTAssertEqual(detailedResult.convertedSize, "34")
        XCTAssertTrue(detailedResult.notes?.contains("brand") == true)
    }
    
    func testMensSwimwear() {
        // Men's swimwear (board shorts/swim briefs)
        let result = ClothingSizeConverter.convert("L", from: .us, to: .eu, type: .swimwear, gender: .men)
        XCTAssertEqual(result, "50", "US men's swimwear L should convert to EU 50")
        
        let numericResult = ClothingSizeConverter.convert("32", from: .us, to: .eu, type: .swimwear, gender: .men)
        XCTAssertEqual(numericResult, "48", "US men's 32 swimwear should convert to EU 48")
    }
    
    func testSwimwearValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("M", for: .swimwear, system: .us, gender: .women))
        XCTAssertTrue(ClothingSizeConverter.isValid("34B", for: .swimwear, system: .us, gender: .women))
        XCTAssertTrue(ClothingSizeConverter.isValid("32", for: .swimwear, system: .us, gender: .men))
        XCTAssertFalse(ClothingSizeConverter.isValid("invalid", for: .swimwear, system: .us, gender: .women))
    }
    
    // MARK: - Plus Size Tests
    
    func testPlusSizeClothing() {
        // Men's plus sizes
        let mensPlusResult = ClothingSizeConverter.convert("2X", from: .us, to: .eu, type: .clothing, gender: .men)
        XCTAssertEqual(mensPlusResult, "54", "US men's 2X should convert to EU 54")
        
        // Women's plus sizes
        let womensPlusResult = ClothingSizeConverter.convert("1X", from: .us, to: .eu, type: .clothing, gender: .women)
        XCTAssertEqual(womensPlusResult, "54", "US women's 1X should convert to EU 54")
        
        // Numeric plus sizes
        let numericPlusResult = ClothingSizeConverter.convert("24", from: .us, to: .eu, type: .clothing, gender: .women)
        XCTAssertEqual(numericPlusResult, "56", "US women's 24 should convert to EU 56")
    }
    
    func testPlusSizeValidation() {
        XCTAssertTrue(ClothingSizeConverter.isValid("1X", for: .clothing, system: .us, gender: .men))
        XCTAssertTrue(ClothingSizeConverter.isValid("2X", for: .clothing, system: .us, gender: .women))
        XCTAssertTrue(ClothingSizeConverter.isValid("24", for: .clothing, system: .us, gender: .women))
        XCTAssertTrue(ClothingSizeConverter.isValid("26", for: .clothing, system: .us, gender: .women))
    }
    
    // MARK: - String Extension Tests
    
    func testStringExtensions() {
        // isClothingSize
        XCTAssertTrue("9.5".isClothingSize, "9.5 should be recognized as clothing size")
        XCTAssertTrue("XL".isClothingSize, "XL should be recognized as clothing size")
        XCTAssertTrue("34B".isClothingSize, "34B should be recognized as clothing size")
        XCTAssertFalse("invalid123!".isClothingSize, "Invalid string should not be recognized")
        
        // normalizedSize
        XCTAssertEqual("9 1/2".normalizedSize, "9.5", "Should normalize fractions")
        XCTAssertEqual("EXTRA LARGE".normalizedSize, "XL", "Should normalize size names")
        XCTAssertEqual("  M  ".normalizedSize, "M", "Should trim whitespace")
        
        // isValidSize
        XCTAssertTrue("9.5".isValidSize(for: .shoe, system: .us, gender: .women))
        XCTAssertFalse("invalid".isValidSize(for: .shoe, system: .us, gender: .women))
        
        // convertSize
        let converted = "9".convertSize(from: .us, to: .eu, type: .shoe, gender: .women)
        XCTAssertEqual(converted, "39", "String extension conversion should work")
    }
    
    // MARK: - Array Extension Tests
    
    func testArrayExtensions() {
        let sizes = ["8", "9", "invalid", "10.5"]
        
        // convertSizes
        let converted = sizes.convertSizes(from: .us, to: .eu, type: .shoe, gender: .women)
        XCTAssertEqual(converted[0], "38")
        XCTAssertEqual(converted[1], "39")
        XCTAssertNil(converted[2])
        XCTAssertEqual(converted[3], "40.5")
        
        // validSizes
        let valid = sizes.validSizes(for: .shoe, system: .us, gender: .women)
        XCTAssertEqual(valid, ["8", "9", "10.5"], "Should filter to only valid sizes")
        
        // normalizedSizes
        let unnormalized = ["9 1/2", "LARGE", "  10  "]
        let normalized = unnormalized.normalizedSizes
        XCTAssertEqual(normalized, ["9.5", "L", "10"], "Should normalize all sizes")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testUnsupportedTypeHandling() {
        // Test what happens with unsupported conversions
        let info = ClothingSizeConverter.conversionInfo()
        XCTAssertTrue(info.supportedTypes.contains(.shoe))
        XCTAssertTrue(info.supportedTypes.contains(.bra))
        XCTAssertTrue(info.supportedTypes.contains(.ring))
        XCTAssertGreaterThan(info.totalConversions, 0)
    }
    
    func testSameSystemConversionClothing() {
        let result = ClothingSizeConverter.convert("M", from: .us, to: .us, type: .clothing, gender: .men)
        XCTAssertEqual(result, "M", "Same system conversion should return normalized input")
    }
    
    // MARK: - Comprehensive Integration Tests
    
    func testAllSupportedTypes() {
        let supportedTypes: [SizeType] = [.shoe, .clothing, .bra, .ring, .hat, .glove, .belt, .sock, .watch, .swimwear]
        
        for type in supportedTypes {
            let info = ClothingSizeConverter.conversionInfo()
            XCTAssertTrue(info.supportedTypes.contains(type), "\(type) should be supported")
            
            if let systems = info.systemsByType[type] {
                XCTAssertGreaterThan(systems.count, 0, "\(type) should have supported systems")
            }
        }
    }
    
    func testMultipleConversionsWithMixedTypes() {
        // Test batch conversions with women's clothing sizes
        let sizes = ["8", "10", "12", "invalid", "14"]
        let results = ClothingSizeConverter.convertMultiple(
            sizes,
            from: .us,
            to: .eu,
            type: .clothing,
            gender: .women
        )
        
        XCTAssertEqual(results.count, 5)
        XCTAssertEqual(results[0], "40") // US Women's 8 → EU 40
        XCTAssertEqual(results[1], "42") // US Women's 10 → EU 42
        XCTAssertEqual(results[2], "44") // US Women's 12 → EU 44
        XCTAssertNil(results[3]) // invalid
        XCTAssertEqual(results[4], "46") // US Women's 14 → EU 46
    }
    
    // MARK: - Extended Integration Tests
    
    func testNewSizeTypeSupport() {
        let info = ClothingSizeConverter.conversionInfo()
        XCTAssertTrue(info.supportedTypes.contains(.swimwear), "Should support swimwear")
        XCTAssertTrue(info.supportedGenders.contains(.infant), "Should support infant sizes")
        XCTAssertTrue(info.supportedGenders.contains(.toddler), "Should support toddler sizes")
        XCTAssertTrue(info.supportedGenders.contains(.youth), "Should support youth sizes")
        
        // Test that we have many conversions now (adjusted expectation based on actual count)
        XCTAssertGreaterThan(info.totalConversions, 200, "Should have many conversion possibilities")
    }
    
    func testChildrensGenderDetection() {
        XCTAssertTrue(Gender.infant.isChildrens)
        XCTAssertTrue(Gender.toddler.isChildrens)
        XCTAssertTrue(Gender.children.isChildrens)
        XCTAssertTrue(Gender.youth.isChildrens)
        XCTAssertFalse(Gender.men.isChildrens)
        XCTAssertFalse(Gender.women.isChildrens)
        XCTAssertFalse(Gender.unisex.isChildrens)
    }
    
    func testMixedSizeConversions() {
        // Test converting various types in one call
        let adultShoe = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .women)
        let childClothing = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .clothing, gender: .children)
        let swimwear = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .swimwear, gender: .women)
        let plusSize = ClothingSizeConverter.convert("1X", from: .us, to: .eu, type: .clothing, gender: .women)
        
        XCTAssertEqual(adultShoe, "39")
        XCTAssertEqual(childClothing, "128")
        XCTAssertEqual(swimwear, "36")
        XCTAssertEqual(plusSize, "54")
    }
    
    func testEdgeCaseConversions() {
        // Test boundary sizes
        let tinyShoe = ClothingSizeConverter.convert("4", from: .us, to: .eu, type: .shoe, gender: .women)
        let hugeShoe = ClothingSizeConverter.convert("16", from: .us, to: .eu, type: .shoe, gender: .women)
        
        // Test unusual but valid inputs
        let paddedSize = ClothingSizeConverter.convert("  9.5  ", from: .us, to: .eu, type: .shoe, gender: .women)
        XCTAssertEqual(paddedSize, "39.5", "Should handle padded input")
    }
    
    func testLargeDatasetConversion() {
        let hugeSizeList = Array(0..<1000).map { "9.\($0 % 10)" }
        measure {
            let _ = ClothingSizeConverter.convertMultiple(hugeSizeList, from: .us, to: .eu, type: .shoe, gender: .women)
        }
    }

    func testUnsupportedSystemCombinations() {
        // Test systems that might not support certain types
        let result = ClothingSizeConverter.convert("M", from: .jp, to: .kr, type: .swimwear, gender: .women)
        // Should handle gracefully
    }
    
    func testCommonUserWorkflows() {
        // Simulate a shopping cart with mixed items
        let shoeSize = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .women)
        let dressSize = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .dress, gender: .women)
        let braSize = ClothingSizeConverter.convert("34B", from: .us, to: .eu, type: .bra)
        
        XCTAssertNotNil(shoeSize)
        XCTAssertNotNil(dressSize)
        XCTAssertNotNil(braSize)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceMultipleConversions() {
        let sizes = Array(repeating: "9", count: 100)
        
        measure {
            let _ = ClothingSizeConverter.convertMultiple(
                sizes,
                from: .us,
                to: .eu,
                type: .shoe,
                gender: .women
            )
        }
    }
    
    func testPerformanceDetailedConversions() {
        measure {
            for _ in 0..<100 {
                let _ = ClothingSizeConverter.convertWithDetails(
                    "9",
                    from: .us,
                    to: .eu,
                    type: .shoe,
                    gender: .women
                )
            }
        }
    }
}
