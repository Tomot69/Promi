import Foundation

enum ShadowWritePolicy {
    // OFF by default: no writes unless explicitly enabled by caller.
    static var isEnabled: Bool = false
}
