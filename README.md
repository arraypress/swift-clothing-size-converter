# Swift Clothing Size Converter

A comprehensive Swift package for converting clothing, shoe, and accessory sizes between international sizing systems. Perfect for e-commerce apps, fashion applications, and international retail platforms.

## Features

- 🌍 **International Support** - Convert between US, UK, EU, FR, IT, JP, AU, and more
- 👕 **Comprehensive Coverage** - Shoes, clothing, bras, rings, hats, gloves, belts, and more
- 👶 **All Ages** - Supports infant, toddler, children's, youth, and adult sizing
- ⚡ **High Performance** - Efficient conversion algorithms with caching
- 🎯 **Confidence Scoring** - Get confidence levels for conversion accuracy
- 🛡️ **Thread-Safe** - Concurrency-safe implementation for modern Swift
- 📱 **Cross-Platform** - Supports iOS, macOS, tvOS, and watchOS

## Installation

### Swift Package Manager

Add ClothingSizeConverter to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-clothing-size-converter.git", from: "1.0.0")
]
```

## Quick Start

```swift
import ClothingSizeConverter

// Convert US women's shoe size 9 to EU
let result = ClothingSizeConverter.convert("9", from: .us, to: .eu, type: .shoe, gender: .women)
// Result: "39"

// Convert men's clothing size
let clothing = ClothingSizeConverter.convert("L", from: .us, to: .eu, type: .clothing, gender: .men)
// Result: "48"
```

## Usage Examples

### Basic Conversions

```swift
// Shoe sizes
let shoes = ClothingSizeConverter.convert("9.5", from: .us, to: .uk, type: .shoe, gender: .women)
// "7"

// Clothing sizes
let dress = ClothingSizeConverter.convert("8", from: .us, to: .eu, type: .dress, gender: .women)
// "40"

// Bra sizes
let bra = ClothingSizeConverter.convert("34B", from: .us, to: .eu, type: .bra)
// "75B"
```

### Detailed Conversions

```swift
let result = ClothingSizeConverter.convertWithDetails(
    "9.5",
    from: .us,
    to: .eu,
    type: .shoe,
    gender: .women
)

print("Original: \(result.originalSize)")
print("Converted: \(result.convertedSize ?? "N/A")")
print("Confidence: \(result.confidence)")
print("Notes: \(result.notes ?? "None")")
```

### Batch Conversions

```swift
let sizes = ["8", "9", "10", "11"]
let converted = ClothingSizeConverter.convertMultiple(
    sizes,
    from: .us,
    to: .eu,
    type: .shoe,
    gender: .women
)
// ["38", "39", "40", "41"]
```

### Size Validation

```swift
let isValid = ClothingSizeConverter.isValid("9.5", for: .shoe, system: .us, gender: .women)
// true

let suggestions = ClothingSizeConverter.getSuggestions(
    for: "9 1/2",
    type: .shoe,
    system: .us,
    gender: .women
)
// ["9.5"]
```

### Children's Sizes

```swift
// Infant sizes (months)
let infant = ClothingSizeConverter.convert("12M", from: .us, to: .eu, type: .clothing, gender: .infant)
// "74"

// Toddler sizes
let toddler = ClothingSizeConverter.convert("3T", from: .us, to: .uk, type: .clothing, gender: .toddler)
// "3"

// Youth sizes
let youth = ClothingSizeConverter.convert("M", from: .us, to: .eu, type: .clothing, gender: .youth)
// "140"
```

### String & Array Extensions

```swift
// String extensions
"9.5".isClothingSize // true
"XL".isValidSize(for: .clothing, system: .us, gender: .men) // true
"9".convertSize(from: .us, to: .eu, type: .shoe, gender: .women) // "39"

// Array extensions
let sizes = ["8", "9", "10"]
sizes.convertSizes(from: .us, to: .eu, type: .shoe, gender: .women)
// ["38", "39", "40"]

sizes.validSizes(for: .shoe, system: .us, gender: .women)
// ["8", "9", "10"]
```

## Supported Size Types

| Type | Systems | Notes |
|------|---------|--------|
| **Shoes** | US, UK, EU, AU, JP, CM | Gender-specific differences |
| **Clothing** | US, UK, EU, FR, IT, AU | Letter and numeric sizes |
| **Bras** | US, UK, EU, FR, AU | Band and cup conversions |
| **Rings** | US, UK, EU, JP, IN, CM | Precise measurements |
| **Hats** | US, UK, EU, CM, IN | Fractional size support |
| **Belts** | US, UK, EU, CM, IN | Waist measurements |
| **Gloves** | US, UK, EU | Letter and numeric |
| **Watches** | Universal | MM measurements |
| **Swimwear** | US, UK, EU, AU | Gender-specific |

## Sizing Systems

- **US** - United States
- **UK** - United Kingdom
- **EU** - European Union
- **FR** - France
- **IT** - Italy
- **JP** - Japan
- **AU** - Australia
- **CM** - Centimeters
- **IN** - Inches

## Gender & Age Support

- **Men's** - Adult men's sizing
- **Women's** - Adult women's sizing
- **Unisex** - Universal sizing (defaults to men's)
- **Infant** - 0-24 months
- **Toddler** - 2T-5T sizes
- **Children** - 4-20 numeric sizes
- **Youth** - XS-XL letter sizes

## API Reference

### Core Methods

#### `convert(_:from:to:type:gender:)`
Basic size conversion with simple string result.

#### `convertWithDetails(_:from:to:type:gender:)`
Detailed conversion with confidence scores and notes.

#### `convertMultiple(_:from:to:type:gender:)`
Batch convert multiple sizes efficiently.

#### `isValid(_:for:system:gender:)`
Validate if a size is valid for the given parameters.

#### `getSuggestions(for:type:system:gender:)`
Get suggestions for invalid or ambiguous sizes.

#### `conversionInfo()`
Get comprehensive information about converter capabilities.

### Confidence Levels

- **0.95-1.0** - Exact table match, very reliable
- **0.85-0.94** - Standard formula conversion, reliable
- **0.70-0.84** - Extrapolated or estimated, good
- **0.50-0.69** - Lower confidence, use with caution

### Error Handling

```swift
let result = ClothingSizeConverter.convertWithDetails("invalid", from: .us, to: .eu, type: .shoe, gender: .women)

if !result.isSuccess {
    switch result.error {
    case .invalidSize(let size):
        print("Invalid size: \(size)")
    case .sizeOutOfRange(let size, let range):
        print("Size \(size) out of range: \(range)")
    case .unsupportedSystem(let system, let type):
        print("\(system) not supported for \(type)")
    default:
        print("Conversion failed")
    }
}
```

## Performance

ClothingSizeConverter is optimized for performance:

- **Basic conversion**: ~0.002ms (cached lookups)
- **Detailed conversion**: ~0.003ms (includes metadata)
- **Batch conversion (100 sizes)**: ~0.2ms total
- **Memory usage**: ~500KB for all conversion tables
- **Thread-safe**: No performance penalty for concurrent access

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 16.0+

## Size Chart References

This library uses industry-standard size charts and conversion formulas from:

- **ISO 3355** - Clothing size designation systems
- **ISO 9407** - Shoe size systems
- **ASTM D5219** - Standard terminology for body dimensions
- **Major retailer size charts** - H&M, Zara, ASOS, Amazon

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

```bash
git clone https://github.com/arraypress/swift-clothing-size-converter.git
cd swift-clothing-size-converter
swift test
```

### Adding New Size Types

1. Create a new converter conforming to `SizeConverterProtocol`
2. Add the size type to `SizeType` enum
3. Update `getConverter(for:)` method
4. Add comprehensive tests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **ISO Standards** - International size standardization
- **Fashion Industry** - Size chart data and validation
- **Open Source Community** - Inspiration and best practices

---

**Made with ❤️ for seamless international shopping**
