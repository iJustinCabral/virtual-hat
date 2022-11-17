//
//  HapticGenerator.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/24/20.
//

import Foundation
import UIKit

enum Haptic {
    case error, success, warning, light, medium, heavy
}

final class HapticGenerator {
    static let shared = HapticGenerator()
    private init() {}
    
    func generateHaptic(_ haptic: Haptic) {
        switch haptic {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
}
