//
//  AVCaptureDevice+Extension.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 28/03/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    private func availableFormatsFor(preferredFps: Float64) -> [AVCaptureDevice.Format] {
        var availableFormats: [AVCaptureDevice.Format] = []
        for format in formats
        {
            let ranges = format.videoSupportedFrameRateRanges
            for range in ranges where range.minFrameRate <= preferredFps && preferredFps <= range.maxFrameRate
            {
                availableFormats.append(format)
            }
        }
        return availableFormats
    }
    
    private func formatWithHighestResolution(_ availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format?
    {
        var maxWidth: Int32 = 0
        var selectedFormat: AVCaptureDevice.Format?
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            let width = dimensions.width
            if width >= maxWidth {
                maxWidth = width
                selectedFormat = format
            }
        }
        return selectedFormat
    }
    
    private func formatFor(preferredSize: CGSize, availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format?
    {
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            
            if dimensions.width >= Int32(preferredSize.width) && dimensions.height >= Int32(preferredSize.height)
            {
                return format
            }
        }
        return nil
    }
    
    func updateFormatWithPreferredVideoSpec(preferredSpec: VideoSpec)
    {
        let availableFormats: [AVCaptureDevice.Format]
        if let preferredFps = preferredSpec.fps {
            availableFormats = availableFormatsFor(preferredFps: Float64(preferredFps))
        }
        else {
            availableFormats = formats
        }
        
        var selectedFormat: AVCaptureDevice.Format?
        if let preferredSize = preferredSpec.size {
            selectedFormat = formatFor(preferredSize: preferredSize, availableFormats: availableFormats)
        } else {
            selectedFormat = formatWithHighestResolution(availableFormats)
        }
        print("selected format: \(String(describing: selectedFormat))")
        
        if let selectedFormat = selectedFormat {
            do {
                try lockForConfiguration()
            }
            catch {
                fatalError("")
            }
            activeFormat = selectedFormat
            
            if let preferredFps = preferredSpec.fps {
                activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                unlockForConfiguration()
            }
        }
    }
}
