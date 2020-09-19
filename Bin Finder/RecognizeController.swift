//
//  RecognizeController.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 23/03/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia
import Vision
import AVFoundation


class RecognizeController:  UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    
    @IBOutlet weak var previewView: UIView!
    
    // some properties used to control the app and store appropriate values
    
    var rectPath : UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    let shapeLayerPath = CAShapeLayer()
    
    func addRect(rect: CGRect)
    {
        let path = UIBezierPath(rect: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height))
        
        rectPath = path
        shapeLayerPath.path = rectPath.cgPath
        //change the fill color
        shapeLayerPath.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayerPath.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayerPath.lineWidth = 2.5
        
        // add the blue-circle layer to the shapeLayer ImageView
        previewView.addSubview(UIVisualEffectView(effect: UIBlurEffect(style: .prominent)))
        shapeLayerPath.animation(forKey: "position")
        previewView.layer.animation(forKey: "addSublayer")
        if(shapeLayerPath.superlayer != nil)
        {
            shapeLayerPath.removeFromSuperlayer()
        }
        previewView.layer.addSublayer(shapeLayerPath)
        print("Shape layer drawn")
        //====================
        
        
       
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
        if touches.first != nil {
           DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                            {
                                self.shapeLayerPath.removeFromSuperlayer()
                            }
            }
        }
        if let device = AVCaptureDevice.default(for: .video) {
        do {
            try device.lockForConfiguration()
            
            device.focusMode = .continuousAutoFocus
        }
            catch {
                // just ignore
            }
    }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let screenSize = previewView.bounds.size
        if let touchPoint = touches.first {
            
            
            let x = touchPoint.location(in: previewView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: previewView).x / screenSize.width
            
            let midX = touchPoint.location(in: previewView).x - 75
            let midY = touchPoint.location(in: previewView).y - 75
            
            let rect = CGRect(origin: CGPoint(x: midX, y: midY), size: CGSize(width: 150, height: 150))
            
            addRect(rect: rect)
            
            
            
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = AVCaptureDevice.default(for: .video) {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .ContinuousAutoFocus
                    //device.focusMode = .autoFocus
                    //device.focusMode = .Locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
          
        super.touchesBegan(touches, with: event)
    }
    
    
}
    
    
        var bufferSize: CGSize = .zero
        var rootLayer: CALayer! = nil
        
        private let session = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer! = nil
        private let videoDataOutput = AVCaptureVideoDataOutput()
        
        private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // to be implemented in the subclass
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupAVCapture()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func setupAVCapture() {
            var deviceInput: AVCaptureDeviceInput!
            
            // Select a video device, make an input
            let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
            do {
                deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
            } catch {
                print("Could not create video device input: \(error)")
                return
            }
            
            session.beginConfiguration()
            session.sessionPreset = .vga640x480 // Model image size is smaller.
            
            // Add a video input
            guard session.canAddInput(deviceInput) else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
            session.addInput(deviceInput)
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
                // Add a video data output
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            } else {
                print("Could not add video data output to the session")
                session.commitConfiguration()
                return
            }
            let captureConnection = videoDataOutput.connection(with: .video)
            // Always process the frames
            captureConnection?.isEnabled = true
            do {
                try  videoDevice!.lockForConfiguration()
                let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
                bufferSize.width = CGFloat(dimensions.width)
                bufferSize.height = CGFloat(dimensions.height)
                videoDevice!.unlockForConfiguration()
            } catch {
                print(error)
            }
            session.commitConfiguration()
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            rootLayer = previewView.layer
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(previewLayer)
        }
        
        func startCaptureSession() {
            session.startRunning()
        }
        
        // Clean up capture setup
        func teardownAVCapture() {
            previewLayer.removeFromSuperlayer()
            previewLayer = nil
        }
        
        func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // print("frame dropped")
        }
        
        public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
            let curDeviceOrientation = UIDevice.current.orientation
            let exifOrientation: CGImagePropertyOrientation
            
            switch curDeviceOrientation {
            case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
                exifOrientation = .left
            case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
                exifOrientation = .upMirrored
            case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
                exifOrientation = .down
            case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
                exifOrientation = .up
            default:
                exifOrientation = .up
            }
            return exifOrientation
        }

    @IBAction func Back(_ sender: Any) {
        let main = self.presentingViewController as! ViewController
        self.dismiss(animated: true) {
            main.reload()
        }
    }

    @IBAction func Done(_ sender: Any) {
        let main = self.presentingViewController as! ViewController
        self.dismiss(animated: true) {
            main.reload()
        }
    }


    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.isTorchActive {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }



    @IBAction func flash(_ sender: Any) {
        toggleTorch()
        
    }
}
