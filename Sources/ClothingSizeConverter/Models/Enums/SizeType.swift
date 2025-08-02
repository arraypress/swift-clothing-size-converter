/// Types of clothing and accessories that can be converted
public enum SizeType: String, CaseIterable, Sendable {
    case shoe = "shoe"
    case clothing = "clothing"
    case dress = "dress"
    case bra = "bra"
    case ring = "ring"
    case hat = "hat"
    case glove = "glove"
    case belt = "belt"
    case pants = "pants"
    case sock = "sock"
    case watch = "watch"
    case jacket = "jacket"
    case swimwear = "swimwear"
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .shoe: return "Shoe Size"
        case .clothing: return "Clothing Size"
        case .dress: return "Dress Size"
        case .bra: return "Bra Size"
        case .ring: return "Ring Size"
        case .hat: return "Hat Size"
        case .glove: return "Glove Size"
        case .belt: return "Belt Size"
        case .pants: return "Pants Size"
        case .sock: return "Sock Size"
        case .watch: return "Watch Size"
        case .jacket: return "Jacket Size"
        case .swimwear: return "Swimwear Size"
        }
    }
}