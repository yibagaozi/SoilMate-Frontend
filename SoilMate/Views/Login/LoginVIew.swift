//
//  LoginVIew.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/1.
//

import SwiftUI

struct LoginView: View {

    @Environment(AuthManager.self) private var authManager

    // MARK: - State

    @State private var isRegisterMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isPasswordVisible = false

    // Animation
    @State private var appeared = false
    @State private var orbOffset1: CGSize = .zero
    @State private var orbOffset2: CGSize = .zero
    @State private var orbOffset3: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // MARK: - Background
                gradientBackground
                floatingOrbs

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        Spacer().frame(height: geo.size.height * 0.08)

                        // Logo
                        logoSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : -20)

                        Spacer().frame(height: 32)

                        // Glass form card
                        glassFormCard
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 30)

                        Spacer().frame(height: 20)

                        // Footer
                        footerText
                            .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 40)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            startOrbAnimation()
        }
    }

    // MARK: - Gradient Background

    private var gradientBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.92, green: 0.98, blue: 0.95),
                Color(red: 0.88, green: 0.97, blue: 0.93),
                Color(red: 0.84, green: 0.95, blue: 0.91),
                Color(red: 0.80, green: 0.94, blue: 0.89),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Floating Orbs (give glass something to blur)

    private var floatingOrbs: some View {
        ZStack {
            // Large orb — top right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.80, green: 0.95, blue: 0.88).opacity(0.35),
                            Color(red: 0.85, green: 0.96, blue: 0.90).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 100, y: -120)
                .offset(orbOffset1)

            // Medium orb — bottom left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.82, green: 0.96, blue: 0.87).opacity(0.3),
                            Color(red: 0.88, green: 0.97, blue: 0.91).opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .offset(x: -100, y: 300)
                .offset(orbOffset2)

            // Small orb — center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.83, green: 0.96, blue: 0.90).opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .offset(x: 40, y: 120)
                .offset(orbOffset3)
        }
        .ignoresSafeArea()
    }

    private func startOrbAnimation() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            orbOffset1 = CGSize(width: -30, height: 40)
        }
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true).delay(1)) {
            orbOffset2 = CGSize(width: 25, height: -35)
        }
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true).delay(2)) {
            orbOffset3 = CGSize(width: -20, height: 30)
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 10) {
            // Placeholder logo
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.mint, Color.mint.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.mint.opacity(0.4), radius: 16, y: 6)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
            }

            Text("SoilMate")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))

            Text("Your plant care companion")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .animation(.easeOut(duration: 0.6).delay(0.2), value: appeared)
    }

    // MARK: - Glass Form Card

    private var glassFormCard: some View {
        VStack(spacing: 0) {

            // Tab switcher
            tabSwitcher
                .padding(.bottom, 24)

            // Form fields
            if isRegisterMode {
                registerFields
            } else {
                loginFields
            }

            // Submit button
            submitButton
                .padding(.top, 20)

            // Divider
            dividerLine
                .padding(.vertical, 20)

            // Social login
            socialButtons
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 28)
        .glassEffect(
            .regular.tint(Color(red: 0.84, green: 0.95, blue: 0.91).opacity(0.15)),
            in: .rect(cornerRadius: 36)
        )
        .animation(.easeInOut(duration: 0.3), value: isRegisterMode)
    }

    // MARK: - Tab Switcher

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton(title: "Log In", isActive: !isRegisterMode) {
                withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                    isRegisterMode = false
                }
            }

            tabButton(title: "Register", isActive: isRegisterMode) {
                withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                    isRegisterMode = true
                }
            }
        }
        .padding(4)
        .glassEffect(.regular, in: .capsule)
    }

    private func tabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isActive ? Color(red: 0.1, green: 0.1, blue: 0.2) : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if isActive {
                        Capsule()
                            .fill(.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Login Fields

    private var loginFields: some View {
        VStack(spacing: 14) {
            inputField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )

            passwordField
        }
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }

    // MARK: - Register Fields

    private var registerFields: some View {
        VStack(spacing: 14) {
            inputField(
                icon: "person.fill",
                placeholder: "Display name",
                text: $displayName,
                keyboardType: .default,
                contentType: .name
            )

            inputField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )

            passwordField
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Input Field

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary.opacity(0.45))
                .frame(width: 20)

            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Password Field

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary.opacity(0.45))
                .frame(width: 20)

            Group {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .font(.system(size: 16))
            .foregroundStyle(.primary)
            .textContentType(isRegisterMode ? .newPassword : .password)

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        VStack(spacing: 0) {
            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isRegisterMode ? "Create Account" : "Log In")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
            }
            .glassEffect(.regular.tint(.mint).interactive())
            .opacity(isFormValid ? 1 : 0.45)
            .disabled(!isFormValid || authManager.isLoading)
            .animation(.easeInOut(duration: 0.25), value: isFormValid)

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Divider

    private var dividerLine: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(height: 0.5)

            Text("OR")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
                .tracking(1.5)

            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(height: 0.5)
        }
    }

    // MARK: - Social Login Buttons

    private var socialButtons: some View {
        HStack(spacing: 12) {
            socialButton(
                icon: "apple.logo",
                label: "Sign in with Apple",
                iconColor: .primary
            ) {
                // TODO: Apple Sign In
            }

            //socialButton(
            //    icon: "g.circle.fill",
            //    label: "Google",
            //    iconColor: .red
            //) {
            //    // TODO: Google Sign In
            //}
        }
    }

    private func socialButton(
        icon: String,
        label: String,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(iconColor)

                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }

    // MARK: - Footer

    private var footerText: some View {
        Text(footerAttributedString)
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 40)
    }

    private var footerAttributedString: AttributedString {
        let linkColor = Color(red: 0.17, green: 0.72, blue: 0.56)

        var text1 = AttributedString("By continuing, you agree to our\n")
        text1.foregroundColor = .secondary

        var terms = AttributedString("Terms")
        terms.foregroundColor = linkColor
        terms.font = .system(size: 13, weight: .medium)

        var text2 = AttributedString(" and ")
        text2.foregroundColor = .secondary

        var privacy = AttributedString("Privacy Policy")
        privacy.foregroundColor = linkColor
        privacy.font = .system(size: 13, weight: .medium)

        return text1 + terms + text2 + privacy
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        let emailOK = email.contains("@") && email.count >= 5
        let passwordOK = password.count >= 8
        if isRegisterMode {
            return emailOK && passwordOK && !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return emailOK && passwordOK
    }

    // MARK: - Submit

    private func submit() async {
        if isRegisterMode {
            await authManager.register(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                displayName: displayName.trimmingCharacters(in: .whitespaces)
            )
        } else {
            await authManager.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environment(AuthManager())
}
