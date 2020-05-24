//
//  CaptureViewController.swift
//  LandonDemo
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

import ARKit
import Foundation
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

}
