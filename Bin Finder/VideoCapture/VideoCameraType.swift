//
//  VideoCameraType.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 23/03/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import AVFoundation


enum CameraType : Int {
    case back
    case front
    
    func captureDevice() -> AVCaptureDevice {
        switch self {
        case .front:
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: AVMediaType.video, position: .front).devices
            print("devices:\(devices)")
            for device in devices where device.position == .front {
                return device
            }
        default:
            break
        }
        return AVCaptureDevice.default(for: AVMediaType.video)!
    }
}
