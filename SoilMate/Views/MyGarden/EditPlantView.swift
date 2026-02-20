//
//  EditPlantView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//
import SwiftUI

struct EditPlantView: View {

    @Environment(\.dismiss) private var dismiss

    // Text fields (editable via UIKit)
    @State private var officialName = "Sansevieria trifasciata"
    @State private var commonName = "Snake Plant"
    @State private var nickname = "MySnakePlant"

    // Pickers
    @State private var waterFrequency = 3
    @State private var waterAmount = 200
    @State private var feedingFrequency = 6
    @State private var feedingType = "General fertilizer"
    @State private var lightRequirement = "Flexible"
    @State private var location = "Living Room"
    @State private var enableNotification = true

    private let waterFrequencyOptions = [3, 5, 7, 10, 14, 21]
    private let feedingFrequencyOptions = [15, 30, 60, 90, 120]
    private let feedingTypeOptions = ["General fertilizer", "Liquid fertilizer", "Slow-release", "Organic"]
    private let lightOptions = ["Full Sun", "Partial Sun", "Low Light", "Flexible"]
    private let locationOptions = ["Living Room", "Bedroom", "Balcony", "Office", "Kitchen"]

    var body: some View {
        List {

            // ── Official Name ──
            Section {
                Text(officialName)
            } header: {
                Text("Official Name")
            }

            // ── Common Name (display only) ──
            Section {
                Text(commonName)
            } header: {
                Text("Common Name")
            }

            // ── Nickname (editable, native SwiftUI) ──
            Section {
                //TextField("Nickname", text: $nickname)
                UIKitTextField(text: $nickname, placeholder: "Nickname")
            } header: {
                Text("Nickname")
            }

            // ── Care Settings ──
            Section {
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
                        ForEach(feedingFrequencyOptions, id: \.self) { months in
                            Button("\(months) Days") { feedingFrequency = months }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(feedingFrequency) Days")
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
                            Button(type) { feedingType = type }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(feedingType)
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
            }
            .listSectionSpacing(20)

            // ── Photo / Location / Notification ──
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

                // Location
                HStack {
                    Text("Location")
                    Spacer()
                    Menu {
                        ForEach(locationOptions, id: \.self) { loc in
                            Button(loc) { location = loc }
                        }
                        Button("Custom…") {
                            presentCustomLocationAlert()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(location)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                }

                // Notification
                Toggle("Notification", isOn: $enableNotification)
                    .tint(.mint)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        // Floating Save button
        .safeAreaInset(edge: .bottom) {
            Button {
                // TODO: Save changes
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
            }
            .buttonStyle(.glassProminent)
            .tint(.mint)
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
                location = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        })
        topVC.present(alert, animated: true)
    }
}

// MARK: - UIKit TextField Wrapper

/// Wraps UITextField for direct text editing with clear button
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
        EditPlantView()
    }
}
