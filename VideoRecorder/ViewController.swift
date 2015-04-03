//
//  ViewController.swift
//  VideoRecorder
//
//  Created by PanaCloud on 3/30/15.
//  Copyright (c) 2015 PanaCloud. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            
            if (device.hasMediaType(AVMediaTypeVideo)){
            
                if(device.position == AVCaptureDevicePosition.Back){
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                    else {
                        
                        println("capture device not found")
                    }
                }
            }
        
        
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func beginSession () {
    
        configureDevice()
        
        var err:NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
        
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        
        
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
            
        }
    
    }
    
    func focusTo(value: Float) {
    
        if let device = captureDevice {
        
            if(device.lockForConfiguration(nil)){
                device.setFocusModeLockedWithLensPosition(value, completionHandler: {(time) -> Void in
                    
                
                })
                device.unlockForConfiguration()
            
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        let touchPer = touchPercent(touches.anyObject() as UITouch)
        focusTo(Float(touchPer.x))
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.x))
        
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let touchPer = touchPercent(touches.anyObject() as UITouch)
    
        focusTo(Float(touchPer.x))
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.x))
    }
    
    func touchPercent(touch:UITouch) -> CGPoint {
        
        let screenSize = UIScreen.mainScreen().bounds.size
        var touchPer = CGPointZero

        if let device = captureDevice {
            
            println("Hello")
            device.lockForConfiguration(nil)
            device.focusPointOfInterest = touch.locationInView(self.view)
            device.unlockForConfiguration()
            println(touch.locationInView(self.view))
        }
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height
        return touchPer
    
    }
    
    func updateDeviceSettings(focusValue: Float, isoValue: Float){
        if let device = captureDevice {
            if (device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: {(time) -> Void in
                
                 })
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                println(maxISO)
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: {(time)->Void in
                })
                device.unlockForConfiguration()
            }
     
        }
    
    
    }


}

