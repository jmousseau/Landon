//
//  CaptureViewController.swift
//  LandonDemo
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

import ARKit
import Foundation
import Landon
import RealityKit
import UIKit

@objc public class CaptureViewController : UIViewController {

    private var arView: ARView? = {
        let arView = ARView(frame: .zero)
        arView.environment.sceneUnderstanding.options = [.occlusion]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.renderOptions = [.disableDepthOfField]
        arView.automaticallyConfigureSession = false
        return arView
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        setUpARView()
        setUpCaptureButton()

        runConfiguration()
    }

    // MARK: - User Interface Setup

    func setUpARView() {
        guard let arView = arView else {
            return
        }

        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)

        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setUpCaptureButton() {
        let captureButton = UIButton(frame: .zero)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.backgroundColor = .systemYellow
        captureButton.layer.cornerRadius = 8

        captureButton.addTarget(
            self,
            action: #selector(captureMesh),
            for: .touchUpInside
        )

        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            captureButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    // MARK: - Session Lifecycle

    private func runConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.environmentTexturing = .automatic
        arView?.session.run(configuration, options: [
            .resetSceneReconstruction,
            .resetTracking
        ])
    }

    // MARK: - Mesh Capture

    @objc private func captureMesh() {
        guard let meshAnchor = self.arView?.session.currentFrame?.anchors.compactMap({ anchor in
            anchor as? ARMeshAnchor
        }).sorted(by: { lhs, rhs in
            lhs.geometry.faces.count > rhs.geometry.faces.count
        }).first else {
            return
        }

        let mesh = LDNDracoMesh(meshGeometry: meshAnchor.geometry)
        let result = mesh.encode()

        guard result.status.code == .OK,
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                         .userDomainMask,
                                                                         true).first else {
                                                                            return
        }

        let url = URL(fileURLWithPath: documentsDirectory, isDirectory: true)
        let path = url.appendingPathComponent("test.drc", isDirectory: false)

        do {
            try result.data?.write(to: path)
        } catch {
            print(error)
        }
    }

}
