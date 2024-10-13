//
//  CaptureController + CaptureDelegate.swift
//  ValifyCaptureKit
//
//  Created by Salah Khaled on 13/10/2024.
//

import UIKit
import AVFoundation

extension CaptureController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        
        if let error = error {
            print("Error processing photo: \(error.localizedDescription)")
            showAlert(title: "Photo Capture Error", message: "Failed to process the photo.")
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("Error: Photo data is invalid")
            return
        }
        
        session?.stopRunning()
        
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        
        view.addSubview(imageView)
    }
}
