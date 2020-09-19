//
//  VideoCapture.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 26/03/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import AVFoundation
import Foundation


struct VideoSpec {
    var fps: Int32?
    var size: CGSize?
}

typealias ImageBufferHandler = ((_ imageBuffer: CMSampleBuffer) -> ())

class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    
    private let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice!
    private var videoConnection: AVCaptureConnection!
    private var audioConnection: AVCaptureConnection!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var imageBufferHandler: ImageBufferHandler?
    
    init(cameraType: CameraType, preferredSpec: VideoSpec?, previewContainer: CALayer?)
    {
        super.init()
        if(cameraType.captureDevice().isFocusModeSupported(.continuousAutoFocus))
        {
            do {
                try cameraType.captureDevice().lockForConfiguration()
                cameraType.captureDevice().focusMode = .continuousAutoFocus
            }
            catch
            {
                //dc
            }
        }
        else if(cameraType.captureDevice().isFocusModeSupported(.autoFocus))
        {
            do {
                try cameraType.captureDevice().lockForConfiguration()
                cameraType.captureDevice().focusMode = .autoFocus
            }
            catch
            {
                //dc
            }
        }
        videoDevice = cameraType.captureDevice()
        
        
        // setup video format
        do {
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            if let preferredSpec = preferredSpec {
                // update the format with a preferred fps
                videoDevice.updateFormatWithPreferredVideoSpec(preferredSpec: preferredSpec)
                
            }
        }
        
        // setup video device input
        do {
            let videoDeviceInput: AVCaptureDeviceInput
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            guard captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
            }
            captureSession.addInput(videoDeviceInput)
        }
        
        // setup preview
        if let previewContainer = previewContainer {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = previewContainer.bounds
            previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewContainer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
        }
        
        // setup video output
        do {
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "com.shu223.videosamplequeue")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            guard captureSession.canAddOutput(videoDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(videoDataOutput)
            
            videoConnection = videoDataOutput.connection(with: AVMediaType.video)
        }
        
    }
    
    
    
    func startCapture() {
        print("\(self.classForCoder)/" + #function)
        if captureSession.isRunning {
            print("already running")
            return
        }
        captureSession.startRunning()
        
    }
    
    
    func stopCapture() {
        print("\(self.classForCoder)/" + #function)
        if !captureSession.isRunning {
            print("already stopped")
            return
        }
        captureSession.stopRunning()
    }
    
    func resizePreview() {
        if let previewLayer = previewLayer {
            guard let superlayer = previewLayer.superlayer else {return}
            previewLayer.frame = superlayer.bounds
        }
        
    }
    
    func focus(focuspoint: CGPoint)
    {
        videoDevice.focusPointOfInterest = focuspoint;
        
    }
    
    
    
    // =========================================================================
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        
        
        if let imageBufferHandler = imageBufferHandler
        {
            imageBufferHandler(sampleBuffer)
        }
    }
    
    
}
