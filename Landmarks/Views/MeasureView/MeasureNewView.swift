import SwiftUI
import AVFoundation

struct MeasureNewView: View {
    // @StateObject 是 SwiftUI 中用于管理状态对象的属性包装器。它负责创建和管理对象的生命周期，并确保视图在状态对象的属性发生变化时自动更新
    // 这里订阅了 VideoRecorderManager 中的isRecording和recordingTime属性，当属性发生改变时，触发视图更新
    @StateObject private var videoRecorderManager = VideoRecorderManager()
    
    var body: some View {
        // ZStack 是 SwiftUI 中的一种布局容器，它允许你将多个视图堆叠在一起，创建一个层叠视图的效果。
        // 每个子视图按顺序添加到堆栈中，最先添加的视图在最底层，最后添加的视图在最顶层。是 z 轴方向的堆叠
        ZStack {
            CameraPreviewView(session: videoRecorderManager.session)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if videoRecorderManager.isRecording {
                    Text(videoRecorderManager.recordingTime)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
                
                Button(action: {
                    if videoRecorderManager.isRecording {
                        videoRecorderManager.stopRecording()
                    } else {
                        videoRecorderManager.startRecording()
                    }
                }) {
                    Text(videoRecorderManager.isRecording ? "停止录制" : "开始录制")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            videoRecorderManager.checkPermissions()
        }
    }
}

class VideoRecorderManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    // @Published 是 Swift 语言中 Combine 框架的一部分，用于属性包装器，它允许对象在其属性发生变化时自动发布通知
    @Published var isRecording = false
    @Published var recordingTime = "00:00:00"
    
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private var timer: Timer?
    private var startTime: Date?
    
    override init() {
        super.init()
        setupSession()
    }
    
    // 配置会话
    func setupSession() {
        session.beginConfiguration()
        
        // 添加摄像头输入
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else { return }
        session.addInput(videoDeviceInput)
        
        // 添加视频输出
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    // 开始录制
    func startRecording() {
        // 设置输出文件路径
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
        startTimer()
        
        // 添加视频数据输出
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
    }
    
    // 停止录制
    func stopRecording() {
        videoOutput.stopRecording()
        isRecording = false
        stopTimer()
        
        // 移除视频数据输出
        session.removeOutput(videoDataOutput)
    }
    
    // 开始计时器
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let hours = Int(elapsed) / 3600
            let minutes = (Int(elapsed) % 3600) / 60
            let seconds = Int(elapsed) % 60
            self.recordingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = "00:00:00"
    }
    
    // 捕获输出帧数据
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // 处理每一帧数据
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            // 在这里可以使用 `uiImage` 进行进一步处理或显示
            print("Frame captured: \(uiImage)")
        }
    }
    
    // 录制完成后的处理
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // 录制完成后的处理逻辑
    }
    
    // 检查权限
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        default:
            print("Permission denied")
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        previewLayer.session = session
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}

