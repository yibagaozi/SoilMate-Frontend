//
//  AddPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI
import VisionKit
import AVFoundation

struct AddPlantView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddPlantViewModel()
    @State private var scannedCode: String? = nil
    @State private var cameraPermissionGranted = false
    @State private var showPotSizeInfo = false

    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21, 30]
    private let feedingOptions = [15, 30, 60, 90, 120]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Medium", "Flexible"]
    private let presetLocations = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    scannerArea
                        .frame(height: 280)
                        .listRowInsets(EdgeInsets())
                }
                .listSectionSpacing(10)

                Section("Plant Information") {
                    plantHeader

                    Button { presentNicknameAlert() } label: {
                        HStack {
                            Text("Nickname").foregroundColor(.primary)
                            Spacer()
                            Text(viewModel.nickname.isEmpty ? "-" : viewModel.nickname)
                                .foregroundColor(.secondary)
                            Text("Edit").foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)

                    // Pot Size
                    HStack {
                        HStack(spacing: 4) {
                            Text("Pot Size")
                            Button {
                                showPotSizeInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showPotSizeInfo, arrowEdge: .bottom) {
                                PotSizeInfoPopover(selectedSize: viewModel.potSize)
                            }
                        }
                        Spacer()
                        PotSizeSelector(selection: $viewModel.potSize)
                    }

                    // Environment
                    HStack {
                        Text("Environment")
                        Spacer()
                        Menu {
                            ForEach(GrowingEnvironment.allCases, id: \.self) { env in
                                Button(env.displayLabel) { viewModel.environment = env }
                            }
                        } label: {
                            menuLabel(viewModel.environment.displayLabel)
                        }
                    }

                    // Location
                    HStack {
                        Text("Location")
                        Spacer()
                        Menu {
                            ForEach(presetLocations, id: \.self) { loc in
                                Button(loc) { viewModel.location = loc }
                            }
                            Button("Custom...") { presentCustomLocationAlert() }
                        } label: {
                            menuLabel(viewModel.location.isEmpty ? "Choose" : viewModel.location)
                        }
                    }

                    Toggle("Notification", isOn: $viewModel.enableNotification)
                        .tint(.mint)
                }

                Section("Caring Schedule") {
                    HStack {
                        Text("Water Frequency")
                        Spacer()
                        Menu {
                            ForEach(waterFrequencyOptions, id: \.self) { days in
                                Button("\(days) Days") { viewModel.waterFrequency = days }
                            }
                        } label: {
                            menuLabel("\(viewModel.waterFrequency) Days")
                        }
                    }

                    HStack {
                        Text("Base Water Amount")
                        Spacer()
                        amountStepper
                    }

                    HStack {
                        Text("Feeding Frequency")
                        Spacer()
                        Menu {
                            ForEach(feedingOptions, id: \.self) { days in
                                Button("\(days) Days") { viewModel.feedingFrequency = days }
                            }
                        } label: {
                            menuLabel("\(viewModel.feedingFrequency) Days")
                        }
                    }

                    HStack {
                        Text("Light Requirements")
                        Spacer()
                        Menu {
                            ForEach(lightOptions, id: \.self) { option in
                                Button(option) { viewModel.lightRequirement = option }
                            }
                        } label: {
                            menuLabel(viewModel.lightRequirement)
                        }
                    }
                }

                Section("Watering") {
                    WateringBlock(
                        baseAmountMl: viewModel.waterAmount,
                        calculatedAmountMl: viewModel.calculatedAmountMl,
                        tags: viewModel.calculationTags
                    )
                }

                if let error = viewModel.errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .safeAreaInset(edge: .bottom) { addButton }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .contentMargins(.top, 8)
        .onAppear {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { cameraPermissionGranted = granted }
            }
        }
        .onChange(of: scannedCode) { _, newValue in
            guard let code = newValue else { return }
            Task { await viewModel.onBarcodeScanned(code) }
        }
        .onChange(of: viewModel.didAddPlant) { _, added in
            if added { dismiss() }
        }
    }

    // MARK: - Reusable bits

    private func menuLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Text(text).foregroundColor(.secondary)
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(.tertiaryLabel))
        }
    }

    private var amountStepper: some View {
        HStack(spacing: 0) {
            Button {
                if viewModel.waterAmount > 50 { viewModel.waterAmount -= 50 }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 20)

            Text("\(viewModel.waterAmount) ml")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .frame(minWidth: 60)

            Divider().frame(height: 20)

            Button {
                viewModel.waterAmount += 50
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var addButton: some View {
        Button {
            Task { await viewModel.addToGarden() }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isAdding {
                    ProgressView().tint(.white)
                } else {
                    Text("Add to My Garden")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
        }
        .buttonStyle(.glassProminent)
        .tint(.mint)
        .disabled(!viewModel.hasPlant || viewModel.isAdding)
        .opacity(viewModel.hasPlant ? 1 : 0.9)
        .padding(.horizontal, 36)
    }

    private var scannerArea: some View {
        ZStack {
            if cameraPermissionGranted &&
                DataScannerViewController.isSupported &&
                DataScannerViewController.isAvailable {
                DataScannerRepresentable(scannedCode: $scannedCode)
            } else {
                Rectangle()
                    .fill(Color(.systemBackground))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Tap to Scan QR Code")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    )
            }

            if viewModel.isScanning {
                Color.black.opacity(0.4)
                    .overlay(
                        ProgressView("Looking up plant...")
                            .tint(.white)
                            .foregroundColor(.white)
                    )
            }
        }
    }

    private var plantHeader: some View {
        HStack(spacing: 12) {
            Group {
                if let urlStr = viewModel.plantImageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        plantImagePlaceholder
                    }
                } else {
                    plantImagePlaceholder
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.plantName)
                    .font(.system(size: 16, weight: .semibold))
                if !viewModel.scientificName.isEmpty {
                    Text(viewModel.scientificName)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            if viewModel.hasPlant {
                HStack(spacing: 4) {
                    Text("Detail").font(.system(size: 15)).foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
    }

    private var plantImagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green.opacity(0.12))
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green.opacity(0.4))
            )
    }

    // MARK: - Alerts

    private func presentNicknameAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Edit nickname", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Enter nickname"
            tf.text = viewModel.nickname
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                viewModel.nickname = text
            }
        })
        topVC.present(alert, animated: true)
    }

    private func presentCustomLocationAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Custom Location", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Enter location" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text,
               !text.trimmingCharacters(in: .whitespaces).isEmpty {
                viewModel.location = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        })
        topVC.present(alert, animated: true)
    }
}

// MARK: - Top VC Helper

extension UIApplication {
    func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}

// MARK: - DataScanner

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        do { try scanner.startScanning() } catch { print("Scanner error: \(error)") }
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: DataScannerRepresentable
        init(parent: DataScannerRepresentable) { self.parent = parent }
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .barcode(let barcode) = item {
                parent.scannedCode = barcode.payloadStringValue
            }
        }
    }
}

#Preview { AddPlantView() }
