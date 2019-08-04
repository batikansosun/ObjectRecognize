//
//  ViewController.swift
//  ObjectRecognize
//
//  Created by Batıkan Sosun on 4.08.2019.
//  Copyright © 2019 Batıkan Sosun. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    var lbl:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
        lbl.frame = CGRect(x: 20, y: view.frame.maxY - 20, width: UIScreen.main.bounds.size.width, height: 20)
        
        
        view.addSubview(lbl)
        
    }
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        
        guard let model = try? VNCoreMLModel(for:Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                self.lbl.text = "\(firstObservation.identifier) : \(firstObservation.confidence)"
            }
            
        }
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
}


