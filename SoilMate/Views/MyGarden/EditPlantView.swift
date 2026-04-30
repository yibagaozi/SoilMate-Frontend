//
//  EditPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI
import PhotosUI

struct EditPlantView: View {

    let userPlantId: Int64

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditPlantViewModel
    @State private var showSaveSuccess = false
    @State private var showPotSizeInfo = false
    @State private var photoItem: PhotosPickerItem?

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
        self._viewModel = State(initialValue: EditPlantViewModel(userPlantId: userPlantId))
    }

    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21]
    private let feedingFrequencyOptions = [15, 30, 60, 90, 120]
    private let feedingTypeOptions = ["General fertilizer", "Liquid fertilizer", "Slow-release", "Organic"]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Flexible"]
    private let locationOptions = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]

    var body: some View {
        List {
            Section {
                Text(viewModel.officialName.isEmpty ? "-" : viewModel.officialName)
            } header: { Text("Official Name") }

            Section {
                Text(viewModel.commonName.isEmpty ? "-" : viewModel.commonName)
            } header: { Text("Common Name") }

            Section {
                UIKitTextField(text: $viewModel.nickname, placeholder: "Nickname")
            } header: { Text("Nickname") }

            Section {
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

                HStack {
                    Text("Location")
                    Spacer()
                    Menu {
                        ForEach(locationOptions, id: \.self) { loc in
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

            Section("Care Settings") {
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
                        ForEach(feedingFrequencyOptions, id: \.self) { days in
                            Button("\(days) Days") { viewModel.feedingFrequency = days }
                        }
                    } label: {
                        menuLabel("\(viewModel.feedingFrequency) Days")
                    }
                }

                HStack {
                    Text("Feeding Type")
                    Spacer()
                    Menu {
                        ForEach(feedingTypeOptions, id: \.self) { type in
                            Button(type) { viewModel.feedingType = type }
                        }
                    } label: {
                        menuLabel(viewModel.feedingType)
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
            .listSectionSpacing(20)

            Section("Watering") {
                WateringBlock(
                    baseAmountMl: viewModel.waterAmount,
                    calculatedAmountMl: viewModel.calculatedAmountMl,
                    tags: viewModel.calculationTags
                )
            }

            // Photo
            Section {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack {
                        Text("Change Photo").foregroundColor(.primary)
                        Spacer()
                        if let img = viewModel.selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else if let existing = viewModel.existingPhotoUrl,
                                  PhotoStorage.isLocal(existing),
                                  let img = PhotoStorage.load(existing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Text("Select").foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error).font(.system(size: 14)).foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.save() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save").font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
            }
            .buttonStyle(.glassProminent)
            .tint(.mint)
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 36)
        }
        .navigationTitle("Edit Plant Information")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundColor(.primary)
                }
            }
        }
        .task { await viewModel.load() }
        .onChange(of: photoItem) { _, newItem in
            Task {
                guard let item = newItem,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let img = UIImage(data: data) else { return }
                await MainActor.run { viewModel.selectedImage = img }
            }
        }
        .onChange(of: viewModel.didSave) { _, saved in
            if saved { showSaveSuccess = true }
        }
        .alert("Saved", isPresented: $showSaveSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Plant information updated successfully.")
        }
    }

    // MARK: - Helpers

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
        if uiView.text != text { uiView.text = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

#Preview {
    NavigationStack {
        EditPlantView(userPlantId: 1)
    }
}
