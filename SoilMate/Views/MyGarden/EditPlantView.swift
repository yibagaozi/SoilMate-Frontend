//
//  EditPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//
import SwiftUI

struct EditPlantView: View {

    let userPlantId: Int64

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditPlantViewModel
    @State private var showSaveSuccess = false
    @State private var showPotSizeInfo = false

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
        self._viewModel = State(initialValue: EditPlantViewModel(userPlantId: userPlantId))
    }

    // Pickers
    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21]
    private let feedingFrequencyOptions = [15, 30, 60, 90, 120]
    private let feedingTypeOptions = ["General fertilizer", "Liquid fertilizer", "Slow-release", "Organic"]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Flexible"]
    private let locationOptions = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]
    private let environmentOptions = ["Indoor", "Outdoor"]
    private let potSizeOptions = ["S", "M", "L", "XL"]

    var body: some View {
        List {

            // ── Official Name ──
            Section {
                Text(viewModel.officialName.isEmpty ? "—" : viewModel.officialName)
            } header: {
                Text("Official Name")
            }

            // ── Common Name (display only) ──
            Section {
                Text(viewModel.commonName.isEmpty ? "—" : viewModel.commonName)
            } header: {
                Text("Common Name")
            }

            // ── Nickname (editable) ──
            Section {
                UIKitTextField(text: $viewModel.nickname, placeholder: "Nickname")
            } header: {
                Text("Nickname")
            }

            // ── Plant Settings ──
            Section {
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
                        ForEach(locationOptions, id: \.self) { loc in
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

            // ── Care Settings ──
            Section("Care Settings") {
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
                        ForEach(feedingFrequencyOptions, id: \.self) { months in
                            Button("\(months) Days") { viewModel.feedingFrequency = months }
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

                // Feeding Type
                HStack {
                    Text("Feeding Type")
                    Spacer()
                    Menu {
                        ForEach(feedingTypeOptions, id: \.self) { type in
                            Button(type) { viewModel.feedingType = type }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.feedingType)
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
            .listSectionSpacing(20)

            // ── Watering Guide ──
            Section("Watering") {
                wateringBlock
            }

            // ── Photo ──
            Section {
                // Change Photo
                HStack {
                    Text("Change Photo")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Select")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
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
        // Floating Save button
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.save() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
            }
            .buttonStyle(.glassProminent)
            .tint(.mint)
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 36)
            .padding(.vertical, 0)
        }
        .navigationTitle("Edit Plant Information")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
        // Load existing data
        .task {
            await viewModel.load()
        }
        // Show success alert after save
        .onChange(of: viewModel.didSave) { _, saved in
            if saved { showSaveSuccess = true }
        }
        // Success alert → dismiss on OK
        .alert("Saved", isPresented: $showSaveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Plant information updated successfully.")
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

    // MARK: - Custom Location Alert (UIKit)

    private func presentCustomLocationAlert() {
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        let alert = UIAlertController(title: "Custom Location",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Enter location"
        }
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

// MARK: - UIKit TextField Wrapper

private struct UIKitTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 17)
        tf.clearButtonMode = .whileEditing
        tf.delegate = context.coordinator
        tf.returnKeyType = .done
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
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

// MARK: - Preview

#Preview {
    NavigationStack {
        EditPlantView(userPlantId: 1)
    }
}
