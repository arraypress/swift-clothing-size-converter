//
//  Dictionary+SizeLookup.swift
//  ClothingSizeConverter
//
//  Created by David Sherlock on 2026.
//

/// Deterministic reverse lookup for size conversion tables.
///
/// Converters map every system's sizes to a shared normalized value (usually the
/// US size) and then look *back* through the target system's table to find the
/// key with a matching value. Several keys can share the same value — e.g. US
/// men's clothing lists `"XXL"`, `"1X"` and `"42"` all at chest `42`, and US
/// women's swimwear lists `"S"`, `"34A"` and `"34B"` all at `4`.
///
/// A plain `for (key, value) in table` loop would return *an arbitrary* one of
/// those keys, because `Dictionary` iteration order is not stable across runs
/// (Swift seeds its hasher per process). That makes the same conversion return
/// different answers on different launches. This helper removes that ambiguity.
internal extension Dictionary where Key == String, Value == Double {

    /// Returns the target key whose value matches `target`, chosen
    /// deterministically when more than one key qualifies.
    ///
    /// Preference order:
    /// 1. A key of the same *kind* as `input` — numeric input prefers a numeric
    ///    key, a letter/lettered input prefers a non-numeric key. This keeps
    ///    round-trips sensible (a numeric size stays numeric where possible).
    /// 2. Failing that, numeric keys (the more universal representation).
    /// 3. Failing that, the remaining keys.
    ///
    /// Ties within the chosen pool are broken numerically when possible and
    /// lexicographically otherwise, so the result is fully reproducible.
    ///
    /// - Parameters:
    ///   - target: The normalized value to match against the table's values.
    ///   - input: The original (normalized) size, used to bias the choice.
    ///   - tolerance: Floating-point match tolerance (default `0.01`).
    /// - Returns: The chosen key, or `nil` if no value matches.
    func sizeKey(matching target: Double, preferring input: String, tolerance: Double = 0.01) -> String? {
        let matches = compactMap { abs($1 - target) < tolerance ? $0 : nil }
        guard matches.count > 1 else { return matches.first }

        let inputIsNumeric = Double(input) != nil
        let sameKind = matches.filter { (Double($0) != nil) == inputIsNumeric }
        let numeric = matches.filter { Double($0) != nil }
        let pool = !sameKind.isEmpty ? sameKind : (!numeric.isEmpty ? numeric : matches)

        return pool.min { lhs, rhs in
            if let l = Double(lhs), let r = Double(rhs) { return l < r }
            return lhs < rhs
        }
    }
}
