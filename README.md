# Swift Clothing Size Converter

A comprehensive Swift package for converting clothing, shoe, and accessory sizes between international sizing systems. It handles shoes, clothing, dresses, bras, rings, hats, gloves, belts, pants, socks, watches, jackets, and swimwear across systems such as US, UK, EU, FR, IT, JP, AU, CN, KR, plus centimeter and inch measurements — with gender-aware logic including dedicated children's sizing.

## Features

- 👟 **13 size types** — shoes, clothing, dresses, bras, rings, hats, gloves, belts, pants, socks, watches, jackets, and swimwear
- 🌍 **11 sizing systems** — US, UK, EU, FR, IT, JP, AU, CN, KR, plus centimeters and inches
- 🚻 **Gender-aware conversions** — men's, women's, unisex, plus children's, infant, toddler, and youth
- 📊 **Detailed results** — `convertWithDetails` returns confidence scores, notes, and error context
- 📦 **Batch conversion** — convert up to 100 sizes at once with `convertMultiple`
- ✅ **Validation** — `isValid` checks a size against a type and system
- 💡 **Suggestions** — `getSuggestions` proposes valid sizes for ambiguous input
- ℹ️ **Capability metadata** — `conversionInfo` reports supported types, systems, and genders
- 🔤 **String & Array extensions** — ergonomic helpers like `convertSize`, `isValidSize`, and `validSizes`
- 🧵 **Sendable models** — value types ready for concurrent use

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-clothing-size-converter.git", from: "1.0.0")
]
```

## Usage

### Basic Conversion

```swift
import ClothingSizeConverter

let euSize = ClothingSizeConverter.convert(
    "9.5",
    from: .us,
    to: .eu,
    type: .shoe,
    gender: .women
)
// e.g. "40.5"
```

### Detailed Conversion

```swift
import ClothingSizeConverter

let result = ClothingSizeConverter.convertWithDetails(
    "34B",
    from: .us,
    to: .uk,
    type: .bra
)

if result.isSuccess {
    print(result.convertedSize ?? "")
    print("Confidence:", result.confidence)
    print("Notes:", result.notes ?? "None")
}
```

### Batch Conversion

```swift
import ClothingSizeConverter

let results = ClothingSizeConverter.convertMultiple(
    ["8", "9", "10", "11"],
    from: .us,
    to: .eu,
    type: .shoe,
    gender: .women
)
// [String?]
```

### Validation and Suggestions

```swift
import ClothingSizeConverter

let valid = ClothingSizeConverter.isValid("34B", for: .bra, system: .us)
let suggestions = ClothingSizeConverter.getSuggestions(for: "9 1/2", type: .shoe, system: .us)
```

### Capability Info

```swift
import ClothingSizeConverter

let info = ClothingSizeConverter.conversionInfo()
print(info.supportedTypes)
print(info.systemsByType)
print(info.totalConversions)
```

### String & Array Extensions

```swift
import ClothingSizeConverter

let converted = "9".convertSize(from: .us, to: .eu, type: .shoe, gender: .women)
let isValid = "34B".isValidSize(for: .bra, system: .us)

let sizes = ["8", "9", "invalid", "10.5"]
let validOnly = sizes.validSizes(for: .shoe, system: .us, gender: .women)
let converted2 = sizes.convertSizes(from: .us, to: .eu, type: .shoe, gender: .women)
```

## How It Works

`ClothingSizeConverter` dispatches each request to a type-specific converter (shoe, bra, ring, etc.), routing children's, infant, toddler, and youth genders to a dedicated children's converter. Conversions use industry-standard lookup tables and return a converted value plus, in detailed mode, a confidence score and explanatory notes.

## Models

### `ConversionResult`

| Property | Type | Description |
|----------|------|-------------|
| `originalSize` | `String` | The input size |
| `convertedSize` | `String?` | The converted size, or nil on failure |
| `fromSystem` | `SizeSystem` | Source sizing system |
| `toSystem` | `SizeSystem` | Target sizing system |
| `type` | `SizeType` | Type of garment/accessory |
| `gender` | `Gender` | Gender context used |
| `confidence` | `Double` | Confidence of the conversion (0.0–1.0) |
| `error` | `ConversionError?` | Error if the conversion failed |
| `notes` | `String?` | Additional notes about the conversion |
| `isSuccess` | `Bool` | Whether the conversion succeeded (computed) |
| `suggestedRange` | `String?` | Suggested range when an exact value is uncertain |

### `ConversionInfo`

| Property | Type | Description |
|----------|------|-------------|
| `supportedTypes` | `[SizeType]` | All supported garment/accessory types |
| `supportedSystems` | `[SizeSystem]` | All supported sizing systems |
| `supportedGenders` | `[Gender]` | All supported gender contexts |
| `systemsByType` | `[SizeType: [SizeSystem]]` | Systems available per type |
| `description` | `String` | Description of the converter |
| `totalConversions` | `Int` | Total possible conversions (computed) |

## Use Cases

- E-commerce and fashion apps with international shipping
- Size recommendation and fit tools
- Retail point-of-sale and catalog systems
- Shortcuts and automation workflows

## Testing

```bash
swift test
```

The test suite covers conversions across each size type and system, gender routing (including children's sizing), validation, suggestions, batch conversion, and the convenience extensions.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
