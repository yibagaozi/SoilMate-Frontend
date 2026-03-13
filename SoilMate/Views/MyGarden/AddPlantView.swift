//
//  AddPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI
import VisionKit
import AVFoundation

// MARK: - Add Plant View

struct AddPlantView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddPlantViewModel()

    @State private var scannedCode: String? = nil
    @State private var cameraPermissionGranted = false

    @State private var showLocationDialog = false
    @State private var showPotSizeInfo = false

    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21, 30]
    private let feedingOptions = [15, 30, 60, 90, 120]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Medium", "Flexible"]
    private let environmentOptions = ["Indoor", "Outdoor", "Greenhouse"]
    private let presetLocations = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]
    private let potSizeOptions = ["S", "M", "L", "XL"]

    var body: some View {
        NavigationStack {
            List {
                // ── Scanner ──
                Section {
                    scannerArea
                        .frame(height: 280)
                        .listRowInsets(EdgeInsets())
                }
                .listSectionSpacing(10)

                // ── Plant Information ──
                Section("Plant Information") {

                    plantHeader

                    // Nickname
                    Button {
                        presentNicknameAlert()
                    } label: {
                        HStack {
                            Text("Nickname")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(viewModel.nickname.isEmpty ? "—" : viewModel.nickname)
                                .foregroundColor(.secondary)
                            Text("Edit")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)

                    // Pot Size — inline segment selector
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
                                potSizeInfoPopover
                            }
                        }
                        Spacer()
                        HStack(spacing: 0) {
                            ForEach(potSizeOptions, id: \.self) { size in
                                Button {
                                    viewModel.potSize = size
                                } label: {
                                    Text(size)
                                        .font(.system(size: 14, weight: viewModel.potSize == size ? .semibold : .regular))
                                        .foregroundColor(viewModel.potSize == size ? .white : .secondary)
                                        .frame(width: 36, height: 30)
                                        .background(
                                            viewModel.potSize == size
                                                ? Color.mint
                                                : Color.clear
                                        )
                                }
                                .buttonStyle(.plain)

                                if size != potSizeOptions.last {
                                    Divider().frame(height: 20)
                                }
                            }
                        }
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Environment
                    HStack {
                        Text("Environment")
                        Spacer()
                        Menu {
                            ForEach(environmentOptions, id: \.self) { option in
                                Button(option) { viewModel.environment = option }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.environment)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
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
                            Button("Custom…") {
                                presentCustomLocationAlert()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.location.isEmpty ? "Choose" : viewModel.location)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }

                    // Notification
                    Toggle("Notification", isOn: $viewModel.enableNotification)
                        .tint(.mint)
                }

                // ── Caring Schedule ──
                Section("Caring Schedule") {

                    // Water Frequency
                    HStack {
                        Text("Water Frequency")
                        Spacer()
                        Menu {
                            ForEach(waterFrequencyOptions, id: \.self) { days in
                                Button("\(days) Days") { viewModel.waterFrequency = days }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(viewModel.waterFrequency) Days")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }

                    // Water Amount
                    HStack {
                        Text("Water Amount")
                        Spacer()
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

                    // Feeding Frequency
                    HStack {
                        Text("Feeding Frequency")
                        Spacer()
                        Menu {
                            ForEach(feedingOptions, id: \.self) { days in
                                Button("\(days) Days") { viewModel.feedingFrequency = days }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(viewModel.feedingFrequency) Days")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }

                    // Light Requirements
                    HStack {
                        Text("Light Requirements")
                        Spacer()
                        Menu {
                            ForEach(lightOptions, id: \.self) { option in
                                Button(option) { viewModel.lightRequirement = option }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.lightRequirement)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }
                }

                // ── Watering ──
                Section("Watering") {
                    wateringBlock
                }

                // ── Error Message ──
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
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await viewModel.addToGarden() }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isAdding {
                            ProgressView()
                                .tint(.white)
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
                .padding(.vertical, 0)
            }
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
            .confirmationDialog(
                "Location",
                isPresented: $showLocationDialog,
                titleVisibility: .visible
            ) {
                ForEach(presetLocations, id: \.self) { loc in
                    Button(loc) { viewModel.location = loc }
                }
                Button("Custom…") {
                    presentCustomLocationAlert()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .contentMargins(.top, 8)
        .onAppear {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                }
            }
        }
        // Barcode scanned → call viewModel
        .onChange(of: scannedCode) { _, newValue in
            guard let code = newValue else { return }
            Task { await viewModel.onBarcodeScanned(code) }
        }
        // Plant added → dismiss
        .onChange(of: viewModel.didAddPlant) { _, added in
            if added { dismiss() }
        }
    }

    // MARK: - Pot Size Info Popover

    private var potSizeInfoPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pot Size Guide")
                .font(.system(size: 15, weight: .semibold))
                .padding(.bottom, 2)

            Text("Sizes refer to the pot's opening diameter.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.bottom, 12)

            ForEach(potSizeGuide, id: \.size) { entry in
                HStack(alignment: .top, spacing: 12) {
                    // Size badge
                    Text(entry.size)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(viewModel.potSize == entry.size ? Color.mint : Color(.systemGray3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.label)
                            .font(.system(size: 14, weight: .medium))
                        Text(entry.description)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, entry.size == "XL" ? 0 : 10)
            }
        }
        .padding(18)
        .frame(width: 280)
        .presentationCompactAdaptation(.popover)
    }

    private struct PotSizeEntry {
        let size: String
        let label: String
        let description: String
    }

    private let potSizeGuide: [PotSizeEntry] = [
        PotSizeEntry(size: "S",  label: "Small  (< 15 cm)",      description: "Fits in one hand. Typically 10–14 cm tall. Ideal for seedlings, succulents, and small herbs."),
        PotSizeEntry(size: "M",  label: "Medium (15–25 cm)",     description: "Standard nursery pot size. Typically 15–22 cm tall. Suits most common houseplants."),
        PotSizeEntry(size: "L",  label: "Large  (25–40 cm)",     description: "Wide, bucket-like opening. Typically 25–35 cm tall. Good for tropical foliage and bushy ferns."),
        PotSizeEntry(size: "XL", label: "Extra Large (> 40 cm)", description: "Floor-standing planter. Often 40 cm or taller. Built for large trees and statement plants."),
    ]

    // MARK: - Watering Block

    private var wateringBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How to Water")
                    .font(.system(size: 16, weight: .bold))
                Text("Allow soil to dry completely between waterings. Water slowly until it drains from the bottom.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Suggested amount")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                Text("≈ ")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Text("\(viewModel.waterAmount)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.blue)
                Text("ml")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            // Context tags
            HStack(spacing: 6) {
                ForEach(wateringTags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// Dynamically build context tags from current selections
    private var wateringTags: [String] {
        var tags: [String] = []
        tags.append("\(viewModel.potSize == "S" ? "Small" : viewModel.potSize == "M" ? "Medium" : viewModel.potSize == "L" ? "Large" : "XL") Pot")
        tags.append(viewModel.environment)
        tags.append("Winter × 0.7")
        return tags
    }

    // MARK: - UIAlertController for Nickname

    private func presentNicknameAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Edit nickname",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Enter nickname"
            tf.text = viewModel.nickname
        }
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                viewModel.nickname = text
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(save)
        topVC.present(alert, animated: true)
    }

    // MARK: - UIAlertController for custom Location

    private func presentCustomLocationAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Custom Location",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Enter location"
        }
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                viewModel.location = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(save)
        topVC.present(alert, animated: true)
    }

    // MARK: - Scanner Area

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

            // Scanning indicator overlay
            if viewModel.isScanning {
                Color.black.opacity(0.4)
                    .overlay(
                        ProgressView("Looking up plant…")
                            .tint(.white)
                            .foregroundColor(.white)
                    )
            }
        }
    }

    // MARK: - Plant Header

    private var plantHeader: some View {
        HStack(spacing: 12) {
            // Plant image
            Group {
                if let urlStr = viewModel.plantImageUrl,
                   let url = URL(string: urlStr) {
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
                    Text("Detail")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
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
}

// MARK: - UIApplication helper to find top VC

private extension UIApplication {
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

// MARK: - VisionKit DataScanner Wrapper

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        do {
            try scanner.startScanning()
        } catch {
            print("Scanner failed to start: \(error)")
        }
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: DataScannerRepresentable

        init(parent: DataScannerRepresentable) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didTapOn item: RecognizedItem) {
            if case .barcode(let barcode) = item {
                parent.scannedCode = barcode.payloadStringValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddPlantView()
}
