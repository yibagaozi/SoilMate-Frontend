//
//  HomeView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

// MARK: - Up Next Data Model

private struct UpNextItem: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let statusText: String
    let statusColor: Color
    let imageName: String?      // nil falls back to leaf placeholder
}

private let upNextItems: [UpNextItem] = [
    UpNextItem(name: "Snake Plant", location: "Living Room",
               statusText: "Tomorrow",  statusColor: .orange, imageName: "IMG_2411"),
    UpNextItem(name: "Succulent",   location: "Balcony",
               statusText: "In 6 Days", statusColor: .blue,   imageName: "IMG_2413"),
    UpNextItem(name: "Monstera",    location: "Office",
               statusText: "In 6 Days", statusColor: .blue,   imageName: "IMG_2414"),
]

// MARK: - Home View

struct HomeView: View {
    private let headerHeight: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    // ── Today's Tasks ──
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Tasks")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        // Full-square card with floating text overlay
                        Image("IMG_2411")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .overlay(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Snake Plant")
                                        .font(.title2)
                                        .fontWeight(.bold)

                                    Text("Living Room")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Watering needed")
                                                .font(.body)
                                                .fontWeight(.semibold)

                                            Text("200ml · scheduled for 8:00 AM")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Button(action: { print("Task completed") }) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                                .frame(width: 30, height: 40)
                                        }
                                        .buttonStyle(.glassProminent)
                                        .tint(.mint)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)          // stretch to full card width
                                .glassEffect(
                                    .regular,
                                    in: .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 30,
                                        bottomTrailingRadius: 30,
                                        topTrailingRadius: 0
                                    )
                                )
                            }
                            .padding(.horizontal)
                    }

                    // ── Up Next ──
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Up Next")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            GlassEffectContainer(spacing: 16) {
                                HStack(spacing: 16) {
                                    ForEach(upNextItems) { item in
                                        VStack(alignment: .leading, spacing: 8) {

                                            // Plant thumbnail — real image or leaf placeholder
                                            if let name = item.imageName {
                                                Image(name)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                            } else {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.green.opacity(0.3))
                                                    .frame(width: 100, height: 100)
                                                    .overlay(
                                                        Image(systemName: "leaf.fill")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(.green.opacity(0.5))
                                                    )
                                            }

                                            Text(item.name)
                                                .font(.headline)
                                            Text(item.location)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(item.statusText)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(item.statusColor)
                                        }
                                        .padding()
                                        .frame(width: 180, alignment: .leading)
                                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 40)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                )
        }
        .padding(.horizontal)
        .padding(.top, 0)
        .padding(.bottom, 16)
        .frame(height: headerHeight, alignment: .center)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
