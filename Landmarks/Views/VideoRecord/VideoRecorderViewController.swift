import UIKit
import AVFoundation
import Photos

class VideoRecorderViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let startButton = UIButton(type: .system)
    let stopButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCaptureSession()
        setupPreviewLayer()
        setupUI()
        checkPermissions()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func setupUI() {
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .red
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 5
        startButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(startButton)
        
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = .green
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 5
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        view.addSubview(stopButton)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stopButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func startRecording() {
        let uuid = UUID()
        print(uuid.uuidString)
        let outputPath = NSTemporaryDirectory() + uuid.uuidString + ".mov"
        let outputURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    @objc func stopRecording() {
        videoOutput.stopRecording()
    }
    
    func checkPermissions() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let photoStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        let group = DispatchGroup()
        
        if videoStatus == .notDetermined {
            group.enter()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.showPermissionAlert()
                }
                group.leave()
            }
        }
        
        if audioStatus == .notDetermined {
            group.enter()
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if !granted {
                    self.showPermissionAlert()
                }
                group.leave()
            }
        }
        
        if photoStatus == .notDetermined {
            group.enter()
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status != .authorized {
                    self.showPermissionAlert()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if videoStatus != .authorized || audioStatus != .authorized || photoStatus != .authorized {
                self.showPermissionAlert()
            }
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "Permission Needed", message: "Please grant camera, microphone, and photo library permissions in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension VideoRecorderViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        guard error == nil else {
//            print("Error recording movie: \(error!.localizedDescription)")
//            return
//        }
        
        // 保存到相册
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                print("Video saved successfully")
            } else {
                print("Error saving video: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
