//
//  ViewController.swift
//  DeviceDetector
//
//  Created by Bobby on 11/18/24.
//
import UIKit
import AVFoundation
import Vision
import CoreML

class DeviceDetectionVC: BaseVC, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var requests = [VNRequest]()
    private let smoothingFactor: CGFloat = 0.8
    private var previousBoundingBoxes: [String: CGRect] = [:]
    private var boundingBoxViews: [String: UIView] = [:]
    private var lastDetectionTime: TimeInterval = 0
    private let detectionInterval: TimeInterval = 0.1
    
    private let targetLabels: Set<String> = [
        "TV Monitor", "microwave", "oven", "toaster", "refrigerator",
        "cell phone", "laptop", "mouse", "remote", "keyboard"
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.layer.zPosition = 10000
        setupCamera()
        setupModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustPreviewLayerFrame()
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            showNoCameraAccessMessage()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.safeAreaLayoutGuide.layoutFrame
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        let instructionLbl = PaddedLabel()
        instructionLbl.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Add padding
        instructionLbl.text = "Hover your camera over a device and click the blue box for more information"
        instructionLbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionLbl.textColor = .white
        instructionLbl.textAlignment = .center
        instructionLbl.translatesAutoresizingMaskIntoConstraints = false
        instructionLbl.clipsToBounds = true
        instructionLbl.backgroundColor = primaryColor
        instructionLbl.layer.cornerRadius = 10
        instructionLbl.numberOfLines = 0
        instructionLbl.layer.zPosition = 10000
        view.addSubview(instructionLbl)
        view.bringSubviewToFront(instructionLbl)
        
        NSLayoutConstraint.activate([
            instructionLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            instructionLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            instructionLbl.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        self.activityIndicator.stopAnimating()
    }

    private func adjustPreviewLayerFrame() {
        // Adjust the frame to respect the navigation bar
        previewLayer?.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    // MARK: - Model Setup
    private func setupModel() {
        guard let model = try? VNCoreMLModel(for: YOLOv3().model) else {
            print("Error loading CoreML model")
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            self?.handleDetectionResults(results)
        }
        requests = [request]
    }
    // MARK: - Handling Detection Results
    private func handleDetectionResults(_ results: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async {
            var currentIdentifiers: Set<String> = []
            
            for observation in results {
                // Get the top label
                guard let topLabel = observation.labels.first else { continue }
                var identifier = topLabel.identifier
                if identifier == "tvmonitor" {
                    identifier = "TV Monitor"
                }
                currentIdentifiers.insert(identifier)

                // Check if the detected label is in the target labels
                if self.targetLabels.contains(identifier) {
                    let boundingBox = observation.boundingBox
                    let scaledBox = self.transformBoundingBox(boundingBox)
                    let smoothedBox = self.smoothBoundingBox(for: identifier, newBox: scaledBox)

                    if let existingBoxView = self.boundingBoxViews[identifier] {
                        // Update the frame of the existing bounding box
                        existingBoxView.frame = smoothedBox
                        if let labelBackground = existingBoxView.subviews.first {
                            labelBackground.frame = CGRect(x: 0, y: 0, width: smoothedBox.width, height: 20)
                        }
                    } else {
                        if !(identifier == "TV Monitor") {
                            identifier = identifier.capitalized
                        }
                        // Create and add a new bounding box
                        let boxView = self.createBoundingBoxView(frame: smoothedBox, label: identifier)
                        self.boundingBoxViews[identifier] = boxView
                        self.view.addSubview(boxView)
                    }
                }
            }

            // Remove outdated bounding boxes
            let identifiersToRemove = self.boundingBoxViews.keys.filter { !currentIdentifiers.contains($0) }
            for identifier in identifiersToRemove {
                self.boundingBoxViews[identifier]?.removeFromSuperview()
                self.boundingBoxViews.removeValue(forKey: identifier)
                self.previousBoundingBoxes.removeValue(forKey: identifier)
            }
        }
    }

    // Smooth bounding box transitions
    private func smoothBoundingBox(for identifier: String, newBox: CGRect) -> CGRect {
        guard let previousBox = previousBoundingBoxes[identifier] else {
            previousBoundingBoxes[identifier] = newBox
            return newBox
        }

        // Interpolate between the previous and new bounding box positions
        let smoothedX = smoothingFactor * previousBox.origin.x + (1 - smoothingFactor) * newBox.origin.x
        let smoothedY = smoothingFactor * previousBox.origin.y + (1 - smoothingFactor) * newBox.origin.y
        let smoothedWidth = smoothingFactor * previousBox.width + (1 - smoothingFactor) * newBox.width
        let smoothedHeight = smoothingFactor * previousBox.height + (1 - smoothingFactor) * newBox.height

        let smoothedBox = CGRect(x: smoothedX, y: smoothedY, width: smoothedWidth, height: smoothedHeight)
        previousBoundingBoxes[identifier] = smoothedBox
        return smoothedBox
    }


     private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
         // Scale the bounding box coordinates to the screen size
         let width = boundingBox.width * view.bounds.width
         let height = boundingBox.height * view.bounds.height
         let x = boundingBox.origin.x * view.bounds.width
         let y = (1 - boundingBox.origin.y - boundingBox.height) * view.bounds.height
         return CGRect(x: x, y: y, width: width, height: height)
     }

     private func createBoundingBoxView(frame: CGRect, label: String) -> UIView {
         let boxView = UIView(frame: frame)
         boxView.layer.borderColor = primaryColor.cgColor
         boxView.layer.borderWidth = 2.0
         boxView.tag = 100 // Tag to identify and remove later

         // Add tap gesture recognizer
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(boundingBoxTapped(_:)))
         boxView.addGestureRecognizer(tapGesture)
         boxView.isUserInteractionEnabled = true
         boxView.accessibilityLabel = label

         // Add label on top of the bounding box
         let labelBackground = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
         labelBackground.backgroundColor = primaryColor
         let identifierLabel = UILabel(frame: labelBackground.bounds)
         identifierLabel.text = label
         identifierLabel.textColor = .white
         identifierLabel.font = UIFont.systemFont(ofSize: 16)
         identifierLabel.textAlignment = .center
         
         labelBackground.addSubview(identifierLabel)
         boxView.addSubview(labelBackground)

         return boxView
     }

    @objc private func boundingBoxTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view?.accessibilityLabel else { return }
        handleDeviceName(label)
    }

    private func handleDeviceName(_ deviceName: String) {
        let specificDeviceVC = GeneratedDeviceVC(deviceName: deviceName)
        navigationController?.pushViewController(specificDeviceVC, animated: true)
    }

    private func showNoCameraAccessMessage() {
        DispatchQueue.main.async {
            let messageLabel = UILabel()
            messageLabel.text = "No camera access"
            messageLabel.textColor = .white
            messageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            messageLabel.textAlignment = .center
            messageLabel.translatesAutoresizingMaskIntoConstraints = false

            self.view.addSubview(messageLabel)

            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }

    // MARK: - Capture Video Frames
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])

        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print("Failed to perform image request: \(error)")
        }
    }
}
