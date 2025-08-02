internal extension String {
    /// Check if string matches a regex pattern
    func matches(_ pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }
    
    /// Extract numeric value from size string
    var numericValue: Double? {
        let cleanString = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleanString)
    }
    
    /// Check if this is a fractional size
    var hasFraction: Bool {
        return contains("/") || contains("1/2") || contains("3/4") || contains("1/4")
    }
    
    /// Get normalized version of this size
    var normalizedSize: String {
        var normalized = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Handle fractions
        normalized = normalized.replacingOccurrences(of: " 1/2", with: ".5")
        normalized = normalized.replacingOccurrences(of: "-1/2", with: ".5")
        normalized = normalized.replacingOccurrences(of: " 3/4", with: ".75")
        normalized = normalized.replacingOccurrences(of: " 1/4", with: ".25")
        
        // Handle common size abbreviations
        let sizeMap = [
            "EXTRA SMALL": "XS", "EXTRA-SMALL": "XS", "XSMALL": "XS",
            "SMALL": "S", "MEDIUM": "M", "LARGE": "L",
            "EXTRA LARGE": "XL", "EXTRA-LARGE": "XL", "XLARGE": "XL",
            "EXTRA EXTRA LARGE": "XXL", "2XL": "XXL", "XXLARGE": "XXL",
            "3XL": "XXXL", "XXXLARGE": "XXXL"
        ]
        
        for (long, short) in sizeMap {
            if normalized == long {
                normalized = short
                break
            }
        }
        
        return normalized
    }
}
