import SwiftUI

struct VideoRecorderView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> VideoRecorderViewController {
        return VideoRecorderViewController()
    }
    
    func updateUIViewController(_ uiViewController: VideoRecorderViewController, context: Context) {
        // 不需要更新 UI
    }
}
