//
//  Haptics.swift
//  Promi
//
//  Created on 25/10/2025.
//

import UIKit
import AudioToolbox
import AVFoundation

class Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func tinyPop() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 0.3)
    }
    
    func gentleNudge() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.5)
    }

    /// Haptic spécifique au pack visuel quand on tape une cellule.
    func packTap(_ pack: String) {
        switch pack {
        case "galets":
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.35)
        case "alveolesSignature":
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
        case "mosaicFlat":
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.4)
        case "spectrumSoft":
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.6)
        case "cristal":
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.45)
        case "vitrailChrome":
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.55)
        case "trame":
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.3)
        default:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    /// Son signature "tenu" — un tom profond et satisfaisant.
    /// Généré en mémoire (95Hz fondamentale + harmonique, decay
    /// exponentiel). Pas de fichier audio nécessaire.
    private var tonePlayer: AVAudioPlayer?

    func playKeptSound() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)

        let sampleRate: Double = 44100
        let duration: Double = 0.38
        let frequency: Double = 95
        let frameCount = Int(sampleRate * duration)

        var samples = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let attack = 1 - exp(-t * 300)
            let decay = exp(-t * 7.5)
            let envelope = attack * decay
            let fundamental = sin(2 * .pi * frequency * t)
            let harmonic = sin(2 * .pi * frequency * 2.0 * t) * 0.25
            let sub = sin(2 * .pi * frequency * 0.5 * t) * 0.15
            samples[i] = Float((fundamental + harmonic + sub) * envelope * 0.55)
        }

        var wavData = Data()
        let dataSize = frameCount * 2
        // RIFF header
        wavData.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        var fileSize = UInt32(36 + dataSize).littleEndian
        wavData.append(Data(bytes: &fileSize, count: 4))
        wavData.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        // fmt
        wavData.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        var chunkSize: UInt32 = 16; wavData.append(Data(bytes: &chunkSize, count: 4))
        var audioFmt: UInt16 = 1; wavData.append(Data(bytes: &audioFmt, count: 2))
        var ch: UInt16 = 1; wavData.append(Data(bytes: &ch, count: 2))
        var rate = UInt32(sampleRate).littleEndian; wavData.append(Data(bytes: &rate, count: 4))
        var byteRate = UInt32(sampleRate * 2).littleEndian; wavData.append(Data(bytes: &byteRate, count: 4))
        var blockAlign: UInt16 = 2; wavData.append(Data(bytes: &blockAlign, count: 2))
        var bps: UInt16 = 16; wavData.append(Data(bytes: &bps, count: 2))
        // data
        wavData.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        var dSize = UInt32(dataSize).littleEndian; wavData.append(Data(bytes: &dSize, count: 4))
        for sample in samples {
            var s = Int16(max(-1, min(1, sample)) * Float(Int16.max))
            wavData.append(Data(bytes: &s, count: 2))
        }

        tonePlayer = try? AVAudioPlayer(data: wavData)
        tonePlayer?.volume = 0.7
        tonePlayer?.play()
    }
}
