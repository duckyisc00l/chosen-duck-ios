// Frames from a simulator recording: swift frames.swift <video> <out dir> [count]
// Writes <out>/f000.png ... evenly spread over the video, 300 points wide at most.
import AVFoundation
import AppKit
let a = CommandLine.arguments
let asset = AVURLAsset(url: URL(fileURLWithPath: a[1]))
let n = a.count > 3 ? Int(a[3]) ?? 24 : 24
let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.maximumSize = CGSize(width: 300, height: 700)
gen.requestedTimeToleranceBefore = CMTime(seconds: 0.5, preferredTimescale: 600)
gen.requestedTimeToleranceAfter = CMTime(seconds: 0.5, preferredTimescale: 600)
let dur = CMTimeGetSeconds(asset.duration)
var done = 0
for i in 0..<n {
    let t = CMTime(seconds: dur * Double(i) / Double(max(n - 1, 1)) * 0.995, preferredTimescale: 600)
    guard let cg = try? gen.copyCGImage(at: t, actualTime: nil),
          let png = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:]) else { continue }
    try? png.write(to: URL(fileURLWithPath: a[2]).appendingPathComponent(String(format: "f%03d.png", i)))
    done += 1
}
print("video \(Int(dur)) s, \(done) frames")
