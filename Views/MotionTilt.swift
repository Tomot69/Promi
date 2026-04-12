import SwiftUI
import Combine
import CoreMotion

@MainActor
final class MotionTilt: ObservableObject {
    static let shared = MotionTilt()
    private let mgr = CMMotionManager()
    private var refCount = 0
    @Published var tilt: CGSize = .zero

    private init() {}

    func subscribe() {
        refCount += 1
        guard refCount == 1, mgr.isDeviceMotionAvailable else { return }
        mgr.deviceMotionUpdateInterval = 1.0 / 60.0
        mgr.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let m = motion else { return }
            let target = CGSize(width: m.gravity.x, height: m.gravity.y)
            self.tilt = CGSize(
                width: self.tilt.width * 0.85 + target.width * 0.15,
                height: self.tilt.height * 0.85 + target.height * 0.15
            )
        }
    }

    func unsubscribe() {
        refCount = max(0, refCount - 1)
        if refCount == 0 { mgr.stopDeviceMotionUpdates() }
    }
}
