//
//  AddPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI
import VisionKit

// MARK: - Add Plant View

struct AddPlantView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var scannedCode: String? = nil

    @State private var nickname = ""
    @State private var waterFrequency = 14
    @State private var waterAmount = 200
    @State private var feedingFrequency = 6
    @State private var lightRequirement = "Flexible"
    @State private var location = ""

    @State private var enableNotification = true

    @State private var showLocationDialog = false

    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21]
    private let feedingOptions = [15, 30, 60, 90, 120]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Flexible"]
    private let presetLocations = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]

    @State private var showNicknameEditor = false
    @State private var tempNickname = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    scannerArea
                        .frame(height: 280)
                        .listRowInsets(EdgeInsets())
                }
                .listSectionSpacing(10)
                

                // ── Plant Information ──
                Section("Plant Information") {

                    plantHeader

                    // Nickname — UIAlertController
                    Button {
                        presentNicknameAlert()
                    } label: {
                        HStack {
                            Text("Nickname")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(nickname.isEmpty ? "—" : nickname)
                                .foregroundColor(.secondary)
                            Text("Edit")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)

                    // Water Frequency
                    HStack {
                        Text("Water Frequency")
                        Spacer()
                        Menu {
                            ForEach(waterFrequencyOptions, id: \.self) { days in
                                Button("\(days) Days") { waterFrequency = days }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(waterFrequency) Days")
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
                                if waterAmount > 50 { waterAmount -= 50 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.plain)

                            Divider().frame(height: 20)

                            Text("\(waterAmount) ml")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .frame(minWidth: 60)

                            Divider().frame(height: 20)

                            Button {
                                waterAmount += 50
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
                            ForEach(feedingOptions, id: \.self) { months in
                                Button("\(months) Days") { feedingFrequency = months }
                            }
                        }
                        label: {
                            HStack(spacing: 4) {
                                Text("\(feedingFrequency) Days")
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
                                Button(option) { lightRequirement = option }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(lightRequirement)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }

                    HStack {
                        Text("Location")
                        Spacer()
                        Menu {
                            ForEach(presetLocations, id: \.self) { loc in
                                Button(loc) { location = loc }
                            }
                            Button("Custom…") {
                                presentCustomLocationAlert()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(location.isEmpty ? "Choose" : location)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }

                    }

                    // Enable Notification
                    Toggle("Enable Notification", isOn: $enableNotification)
                        .tint(.mint)
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .safeAreaInset(edge: .bottom) {
                Button {
                    print("Add to My Garden")
                } label: {
                    Text("Add to My Garden")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
                .buttonStyle(.glassProminent)
                .tint(.mint)
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
            // Location
            .confirmationDialog(
                "Location",
                isPresented: $showLocationDialog,
                titleVisibility: .visible
            ) {
                ForEach(presetLocations, id: \.self) { loc in
                    Button(loc) { location = loc }
                }
                Button("Custom…") {
                    presentCustomLocationAlert()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .contentMargins(.top, 8)
    }

    // MARK: - UIAlertController for Nickname

    private func presentNicknameAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Edit nickname",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Enter nickname"
            tf.text = nickname
        }
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                nickname = text
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
                location = text.trimmingCharacters(in: .whitespacesAndNewlines)
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
            if DataScannerViewController.isSupported &&
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
        }
    }

    // MARK: - Plant Header

    private var plantHeader: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.12))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green.opacity(0.4))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Snake Plant")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sansevieria trifasciata")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .italic()
            }

            Spacer()

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
        try? scanner.startScanning()
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
