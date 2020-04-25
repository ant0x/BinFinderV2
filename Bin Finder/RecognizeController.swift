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


class RecognizeController: UIViewController, UIImagePickerControllerDelegate {
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    // Outlets to label and view
    @IBOutlet private weak var predictLabel: UILabel!
    @IBOutlet private weak var previewView: UIView!
    
    @IBOutlet weak var OverlayView: UIView!
    
    // some properties used to control the app and store appropriate values
    
    var rectPath : UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    let shapeLayerPath = CAShapeLayer()
    
    func addRect(rect: CGRect)
    {
        var path = UIBezierPath(rect: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height))
        
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
                    device.focusMode = .autoFocus
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




let TrashModel = Trash_Identifier()
private var videoCapture: VideoCapture!
private var requests = [VNRequest]()

override func viewDidLoad() {
    super.viewDidLoad()
    setupVision()
    
    let spec = VideoSpec(fps: 30, size: CGSize(width: 3840, height: 2160))
    videoCapture = VideoCapture(cameraType: .back,
                                preferredSpec: spec,
                                previewContainer: previewView.layer)
    
    videoCapture.imageBufferHandler = {[unowned self] (imageBuffer) in
        
        // Use Vision
        self.handleImageBufferWithVision(imageBuffer: imageBuffer)
        
        /*
         // Use Core ML
         self.handleImageBufferWithCoreML(imageBuffer: imageBuffer)
         */
        
    }
}

func handleImageBufferWithCoreML(imageBuffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
        return
    }
    do {
        let prediction = try self.TrashModel.prediction(image: self.resize(pixelBuffer: pixelBuffer)!)
        DispatchQueue.main.async {
            if let prob = prediction.classLabelProbs[prediction.classLabel] {
                // \(String(describing: prob))   for the index of type double of probability
                self.predictLabel.text = "\(prediction.classLabel)"
                if prob < 0.5
                {
                    print(prob)
                    self.predictLabel.text = "Can't recognize it"
                }
            }
        }
    }
    catch let error as NSError {
        fatalError("Unexpected error ocurred: \(error.localizedDescription).")
    }
}

func handleImageBufferWithVision(imageBuffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
        return
    }
    
    var requestOptions:[VNImageOption : Any] = [:]
    
    if let cameraIntrinsicData = CMGetAttachment(imageBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
        requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
    }
    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: UInt32(self.exifOrientationFromDeviceOrientation))!, options: requestOptions)
    do {
        try imageRequestHandler.perform(self.requests)
    } catch {
        print(error)
    }
}

func setupVision() {
    guard let visionModel = try? VNCoreMLModel(for: TrashModel.model) else {
        fatalError("can't load Vision ML model")
    }
    let classificationRequest = VNCoreMLRequest(model: visionModel) { (request: VNRequest, error: Error?) in
        guard let observations = request.results else {
            print("no results:\(error!)")
            return
        }
        
        let classifications = observations[0...4]
            .compactMap({ $0 as? VNClassificationObservation })
            .filter({ $0.confidence > 0.2 })
            .map({ "\($0.identifier) " }) //\($0.confidence)
        DispatchQueue.main.async {
            self.predictLabel.text = classifications.joined(separator: "\n")
        }
    }
    classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
    
    self.requests = [classificationRequest]
    
}


/// only support back camera
var exifOrientationFromDeviceOrientation: Int32 {
    let exifOrientation: DeviceOrientation
    enum DeviceOrientation: Int32 {
        case top0ColLeft = 1
        case top0ColRight = 2
        case bottom0ColRight = 3
        case bottom0ColLeft = 4
        case left0ColTop = 5
        case right0ColTop = 6
        case right0ColBottom = 7
        case left0ColBottom = 8
    }
    switch UIDevice.current.orientation {
    case .portraitUpsideDown:
        exifOrientation = .left0ColBottom
    case .landscapeLeft:
        exifOrientation = .top0ColLeft
    case .landscapeRight:
        exifOrientation = .bottom0ColRight
    default:
        exifOrientation = .right0ColTop
    }
    return exifOrientation.rawValue
}


/// resize CVPixelBuffer
///
/// - Parameter pixelBuffer: CVPixelBuffer by camera output
/// - Returns: CVPixelBuffer with size (299, 299)
func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
    let imageSide = 299
    var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
    let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
    ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
    let ciContext = CIContext()
    var resizeBuffer: CVPixelBuffer?
    CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &resizeBuffer)
    ciContext.render(ciImage, to: resizeBuffer!)
    return resizeBuffer
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let videoCapture = videoCapture else {return}
    videoCapture.startCapture()
}

override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let videoCapture = videoCapture else {return}
    videoCapture.resizePreview()
}

override func viewWillDisappear(_ animated: Bool) {
    guard let videoCapture = videoCapture else {return}
    videoCapture.stopCapture()
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    super.viewWillDisappear(animated)
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
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


