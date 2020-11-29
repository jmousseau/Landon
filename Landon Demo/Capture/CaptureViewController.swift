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

    private let captureQueue: DispatchQueue

    public init() {
        captureQueue = DispatchQueue(label: "Landon Anchor Capture")

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

        runWorldTrackingConfiguration()
        // runFaceTrackingConfiguration()
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
        let captureButton = CaptureButton(frame: .zero)
        captureButton.addTarget(
            self,
            action: #selector(captureAnchors),
            for: .touchUpInside
        )

        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    // MARK: - Session Lifecycle

    private func runWorldTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.sceneReconstruction = .meshWithClassification
        run(configuration: configuration)
    }

    private func runFaceTrackingConfiguration() {
        run(configuration: ARFaceTrackingConfiguration())
    }

    private func run(configuration: ARConfiguration) {
        arView?.session.run(configuration, options: [
            .resetSceneReconstruction,
            .resetTracking
        ])
    }

    // MARK: - Mesh Capture

    @objc private func captureAnchors() {
        guard let frame = self.arView?.session.currentFrame,
              !frame.anchors.isEmpty else {
            return
        }

        let faceAnchors = frame.anchors.compactMap({ anchor in
            anchor as? ARFaceAnchor
        })

        let meshAnchors = frame.anchors.compactMap({ anchor in
            anchor as? ARMeshAnchor
        })

        let planeAnchors = frame.anchors.compactMap({ anchor in
            anchor as? ARPlaneAnchor
        })

        captureQueue.async { [weak self] in
            self?.capture(faceAnchors: faceAnchors)
            self?.capture(meshAnchors: meshAnchors)
            self?.capture(planeAnchors: planeAnchors)
        }
    }

    private func capture(faceAnchors: [ARFaceAnchor]) {
        guard !faceAnchors.isEmpty else {
            return
        }

        let result = DracoEncoder.encode(faceAnchors: faceAnchors)

        guard result.status.code == .OK, let contents = result.data else {
            return
        }

        write(contents: contents, to: "face-anchors.drc")
    }

    private func capture(meshAnchors: [ARMeshAnchor]) {
        guard !meshAnchors.isEmpty else {
            return
        }

        let result = DracoEncoder.encode(meshAnchors: meshAnchors)

        guard result.status.code == .OK, let contents = result.data else {
            return
        }

        write(contents: contents, to: "mesh-anchors.drc")
    }

    private func capture(planeAnchors: [ARPlaneAnchor]) {
        guard !planeAnchors.isEmpty else {
            return
        }

        let result = DracoEncoder.encode(planeAnchors: planeAnchors)

        guard result.status.code == .OK, let contents = result.data else {
            return
        }

        write(contents: contents, to: "plane-anchors.drc")
    }

    // MARK: - File System

    func write(contents: Data, to file: String) {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first else {
            return
        }

        let url = URL(fileURLWithPath: documentsDirectory, isDirectory: true)
        let path = url.appendingPathComponent(file, isDirectory: false)

        do {
            try contents.write(to: path)
        } catch {
            print(error)
        }
    }

}
