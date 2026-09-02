import AVFoundation

final class SoundManager {
    static let shared = SoundManager()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isConfigured = false
    private var settings: GameplaySettings { GameplaySettings.shared }

    private init() {
        configureSession()
    }

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Simulator or silent mode — tones may not play.
        }
    }

    private func ensureEngine() {
        guard !isConfigured else { return }
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
            isConfigured = true
        } catch {
            isConfigured = false
        }
    }

    func playSkip(combo: Int) {
        let frequency = 520 + Double(min(combo, 10)) * 38
        playTone(frequency: frequency, duration: 0.07, volume: 0.22, decay: 0.92)
    }

    func playBounce() {
        playTone(frequency: 280, duration: 0.05, volume: 0.14, decay: 0.85)
    }

    func playDoubleBounce() {
        playTone(frequency: 640, duration: 0.06, volume: 0.2, decay: 0.9)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) { [weak self] in
            self?.playTone(frequency: 780, duration: 0.05, volume: 0.18, decay: 0.88)
        }
    }

    func playPearl() {
        playTone(frequency: 880, duration: 0.05, volume: 0.12, decay: 0.95)
    }

    func playLaunch() {
        playTone(frequency: 220, duration: 0.12, volume: 0.16, decay: 0.75)
    }

    func playSink() {
        playTone(frequency: 160, duration: 0.25, volume: 0.1, decay: 0.6)
    }

    func playNewBest() {
        playTone(frequency: 660, duration: 0.08, volume: 0.18, decay: 0.92)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.playTone(frequency: 880, duration: 0.1, volume: 0.16, decay: 0.9)
        }
    }

    func playMenuTap() {
        playTone(frequency: 420, duration: 0.04, volume: 0.08, decay: 0.9)
    }

    func playBiomeShift() {
        playTone(frequency: 340, duration: 0.2, volume: 0.1, decay: 0.8)
    }

    func playBoost() {
        playTone(frequency: 720, duration: 0.09, volume: 0.22, decay: 0.88)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
            self?.playTone(frequency: 960, duration: 0.07, volume: 0.16, decay: 0.9)
        }
    }

    private func playTone(frequency: Double, duration: Double, volume: Float, decay: Double) {
        guard settings.soundEnabled else { return }
        ensureEngine()
        guard isConfigured else { return }

        let sampleRate = 44_100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return }

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let envelope = pow(decay, time / duration)
            channel[frame] = Float(sin(2 * .pi * frequency * time) * envelope) * volume
        }

        player.scheduleBuffer(buffer, completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
}
