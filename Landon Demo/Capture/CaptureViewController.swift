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
import UniformTypeIdentifiers

@objc public class CaptureViewController : UIViewController {

    private var arView: ARView? = {
        let arView = ARView(frame: .zero)
        arView.environment.sceneUnderstanding.options = [.occlusion]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.renderOptions = [.disableDepthOfField]
        arView.automaticallyConfigureSession = false
        return arView
    }()

    private var exportDirectoryButton: UIButton = {
        let exportDirectoryButton = UIButton(frame: .zero)
        exportDirectoryButton.backgroundColor = .systemGray5
        exportDirectoryButton.tintColor = .systemYellow
        exportDirectoryButton.setTitleColor(.systemYellow, for: .normal)
        exportDirectoryButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 32)
        exportDirectoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        exportDirectoryButton.clipsToBounds = true
        exportDirectoryButton.layer.cornerCurve = .continuous
        exportDirectoryButton.layer.cornerRadius = 16

        exportDirectoryButton.addTarget(
            self,
            action: #selector(selectExportDirectory),
            for: .touchUpInside
        )

        return exportDirectoryButton
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
        let captureButton = setUpCaptureButton()
        setUpFlipCameraButton(captureButton: captureButton)
        setUpExportDirectoryButton()

        updateExportDirectoryButtonTitle()
        runWorldTrackingConfiguration()
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

    @discardableResult func setUpCaptureButton() -> CaptureButton {
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

        return captureButton
    }

    func setUpFlipCameraButton(captureButton: CaptureButton) {
        let flipCameraButton = UIButton(frame: .zero)
        flipCameraButton.tintColor = .white
        flipCameraButton.backgroundColor = .systemGray5
        flipCameraButton.setImage(UIImage(
            systemName: "arrow.triangle.2.circlepath",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)
        ), for: .normal)

        flipCameraButton.addTarget(
            self,
            action: #selector(toggleConfiguration),
            for: .touchUpInside
        )

        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flipCameraButton)

        let widthConstraint = flipCameraButton.widthAnchor.constraint(equalToConstant: 50)

        NSLayoutConstraint.activate([
            flipCameraButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            flipCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            widthConstraint,
            flipCameraButton.heightAnchor.constraint(equalToConstant: widthConstraint.constant),
        ])

        flipCameraButton.clipsToBounds = true
        flipCameraButton.layer.cornerCurve = .circular
        flipCameraButton.layer.cornerRadius = widthConstraint.constant / 2
    }

    func setUpExportDirectoryButton() {
        exportDirectoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exportDirectoryButton)

        NSLayoutConstraint.activate([
            exportDirectoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportDirectoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    // MARK: - Session Lifecycle

    @objc private func toggleConfiguration() {
        if arView?.session.configuration is ARWorldTrackingConfiguration {
            runFaceTrackingConfiguration()
        } else {
            runWorldTrackingConfiguration()
        }
    }

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

    // MARK: - Export Directory

    @objc private func selectExportDirectory() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    private func updateExportDirectoryButtonTitle() {
        if let exportDirectory = resolveExportDirectory() {
            exportDirectoryButton.setTitle(exportDirectory.lastPathComponent, for: .normal)
            exportDirectoryButton.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        } else {
            exportDirectoryButton.setTitle("Select Export Folder", for: .normal)
            exportDirectoryButton.setImage(UIImage(systemName: "questionmark.folder.fill"), for: .normal)
        }
    }

    private func resolveExportDirectory() -> URL? {
        guard let bookmarkData = Defaults.exportDirectory else { return nil }
        var isStale = false
        guard let exportDirectory = try? URL(
            resolvingBookmarkData: bookmarkData,
            bookmarkDataIsStale: &isStale
        ), !isStale else { return nil }
        return exportDirectory
    }

    // MARK: - File System

    func write(contents: Data, to file: String) {
        if let exportDirectory = resolveExportDirectory() {
            write(contents: contents, to: file, in: exportDirectory)
        } else {
            guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            ).first else {
                return
            }

            let url = URL(fileURLWithPath: documentsDirectory, isDirectory: true)
            write(contents: contents, to: file, in: url)
        }
    }

    func write(contents: Data, to file: String, in directory: URL) {
        let path = directory.appendingPathComponent(file, isDirectory: false)
        try? contents.write(to: path)
    }

}

extension CaptureViewController : UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        Defaults.exportDirectory = try? url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )

        updateExportDirectoryButtonTitle()
    }

}
