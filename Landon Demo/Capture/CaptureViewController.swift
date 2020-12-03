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

public enum GeometryFileFormat: String, CaseIterable {

    case draco = "drc"

    case obj = "obj"

}

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
        exportDirectoryButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 24)
        exportDirectoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
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

    private var currentExportFileFormatIndex = 0 {
        didSet {
            updateExportFileFormatButtonTitle()
        }
    }

    private var currentExportFileFormat: GeometryFileFormat {
        GeometryFileFormat.allCases[currentExportFileFormatIndex]
    }

    private var exportFileFormatButton: UIButton = {
        let exportFileFormatButton = UIButton(frame: .zero)
        exportFileFormatButton.backgroundColor = .systemGray5
        exportFileFormatButton.tintColor = .systemYellow
        exportFileFormatButton.setTitleColor(.systemYellow, for: .normal)
        exportFileFormatButton.titleLabel?.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        exportFileFormatButton.setImage(UIImage(systemName: "cube"), for: .normal)
        exportFileFormatButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 24)
        exportFileFormatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)

        exportFileFormatButton.addTarget(
            self,
            action: #selector(rotateExportFileFormat),
            for: .touchUpInside
        )

        return exportFileFormatButton
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
        setUpExportFileFormatButton(captureButton: captureButton)
        setUpExportDirectoryButton()

        updateExportFileFormatButtonTitle()
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

        let leadingLayoutGuide = UILayoutGuide()
        let trailingLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(leadingLayoutGuide)
        view.addLayoutGuide(trailingLayoutGuide)

        let widthConstraint = flipCameraButton.widthAnchor.constraint(equalToConstant: 50)

        NSLayoutConstraint.activate([
            leadingLayoutGuide.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor),
            leadingLayoutGuide.trailingAnchor.constraint(equalTo: flipCameraButton.leadingAnchor),
            trailingLayoutGuide.leadingAnchor.constraint(equalTo: flipCameraButton.trailingAnchor),
            trailingLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            leadingLayoutGuide.widthAnchor.constraint(equalTo: trailingLayoutGuide.widthAnchor),
            flipCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            widthConstraint,
            flipCameraButton.heightAnchor.constraint(equalToConstant: widthConstraint.constant)
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

    func setUpExportFileFormatButton(captureButton: CaptureButton) {
        exportFileFormatButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exportFileFormatButton)

        exportFileFormatButton.clipsToBounds = true
        exportFileFormatButton.layer.cornerCurve = .continuous
        exportFileFormatButton.layer.cornerRadius = 16

        exportFileFormatButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exportFileFormatButton)

        let leadingLayoutGuide = UILayoutGuide()
        let trailingLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(leadingLayoutGuide)
        view.addLayoutGuide(trailingLayoutGuide)

        let heightConstraint = exportFileFormatButton.heightAnchor.constraint(equalToConstant: 50)

        NSLayoutConstraint.activate([
            leadingLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            leadingLayoutGuide.trailingAnchor.constraint(equalTo: exportFileFormatButton.leadingAnchor),
            trailingLayoutGuide.leadingAnchor.constraint(equalTo: exportFileFormatButton.trailingAnchor),
            trailingLayoutGuide.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor),
            leadingLayoutGuide.widthAnchor.constraint(equalTo: trailingLayoutGuide.widthAnchor),
            exportFileFormatButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            heightConstraint
        ])

        exportFileFormatButton.clipsToBounds = true
        exportFileFormatButton.layer.cornerCurve = .circular
        exportFileFormatButton.layer.cornerRadius = heightConstraint.constant / 2
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

        let name = "face-anchors"

        switch currentExportFileFormat {
        case .draco:
            let result = DracoEncoder.encode(faceAnchors: faceAnchors)
            if result.status.code == .OK, let contents = result.data {
                write(contents: contents, name: name)
            }
        case .obj:
            if let contents = OBJEncoder.encode(faceAnchors: faceAnchors) {
                write(contents: contents, name: name)
            }
        }
    }

    private func capture(meshAnchors: [ARMeshAnchor]) {
        guard !meshAnchors.isEmpty else {
            return
        }

        let name = "mesh-anchors"

        switch currentExportFileFormat {
        case .draco:
            let result = DracoEncoder.encode(meshAnchors: meshAnchors)
            if result.status.code == .OK, let contents = result.data {
                write(contents: contents, name: name)
            }
        case .obj:
            if let contents = OBJEncoder.encode(meshAnchors: meshAnchors) {
                write(contents: contents, name: name)
            }
        }
    }

    private func capture(planeAnchors: [ARPlaneAnchor]) {
        guard !planeAnchors.isEmpty else {
            return
        }

        let name = "plane-anchors"

        switch currentExportFileFormat {
        case .draco:
            let result = DracoEncoder.encode(planeAnchors: planeAnchors)
            if result.status.code == .OK, let contents = result.data {
                write(contents: contents, name: name)
            }
        case .obj:
            if let contents = OBJEncoder.encode(planeAnchors: planeAnchors) {
                write(contents: contents, name: name)
            }
        }
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

    // MARK: - Export File Format

    @objc private func rotateExportFileFormat() {
        currentExportFileFormatIndex = (currentExportFileFormatIndex + 1) % GeometryFileFormat.allCases.count
    }

    private func updateExportFileFormatButtonTitle() {
        exportFileFormatButton.setTitle(currentExportFileFormat.rawValue.uppercased(), for: .normal)
    }

    // MARK: - File System

    func write(contents: Data, name: String) {
        write(contents: contents, file: "\(name).\(currentExportFileFormat.rawValue)")
    }

    func write(contents: Data, file: String) {
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
