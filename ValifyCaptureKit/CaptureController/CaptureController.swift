//
//  CaptureController.swift
//  ValifyCaptureKit
//
//  Created by Salah Khaled on 13/10/2024.
//

import UIKit
import AVFoundation

public class CaptureController: UIViewController {
    
    // MARK: - Properties
    internal var delegate: ValifyCaptureRouter
    internal var session: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let output = AVCapturePhotoOutput()
    
    private var shutterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return button
    }()
    
    // MARK: - Init
    public init(delegate: ValifyCaptureRouter) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermission()
    }
//    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if session?.isRunning == false {
//            
//        }
//    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }
    
    deinit {
        session?.stopRunning()
        previewLayer.session = nil
        session = nil
    }
    
    
    // MARK: - Methods
    private func setupUI() {
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        shutterButton.addTarget(self, action: #selector(didClickShutterButton), for: .touchUpInside)
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { isGranted in
                guard isGranted else { return }
                
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            break
        default:
            break
        }
    }
    
    private func setupCamera() {
        
        guard session == nil else { return }
        let session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                // Start session on a background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
                
                self.session = session
            } catch {
                print("Error setting up the camera: \(error.localizedDescription)")
                showAlert(title: "Camera Error", message: "Failed to setup the camera.")
            }
        }
    }
    
    internal func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    
    // MARK: - Actions
    @objc private func didClickShutterButton() {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }

}
