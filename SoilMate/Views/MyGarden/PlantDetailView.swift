//
//  PlantDetailView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI

struct PlantDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var showEditPlant = false

    var body: some View {
        //NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // MARK: Plant Photo
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 160, height: 160)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.green.opacity(0.3))
                        )
                        .padding(.horizontal)

                    // MARK: Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MySnakePlant")
                            .font(.system(size: 30, weight: .bold))

                        Text("Snake Plant · Sansevieria trifasciata")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.horizontal)

                    // MARK: Watering + Feeding
                    HStack(alignment: .top, spacing: 12) {
                        wateringCard
                        feedingCard
                    }
                    .padding(.horizontal)

                    // MARK: Below
                    HStack(alignment: .top, spacing: 12) {

                        VStack(spacing: 12) {
                            infoCard(title: "Light", value: "Flexible")
                            infoCard(title: "Notification", value: "Enabled")
                            infoCard(title: "Location", value: "Living Room")
                        }

                        historyCard
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Plant Detail Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditPlant = true
                        } label: {
                            Label("Edit Plant Information", systemImage: "square.and.pencil")
                                .foregroundStyle(.primary) // 图标 + 文字保持系统黑
                        }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Plant", systemImage: "trash")
                                .foregroundStyle(.red) // 强制红色
                        }

                    } label: {
                        Image(systemName: "square.on.square")
                            .foregroundColor(.primary) // 只给触发按钮上色
                    }
                    .tint(nil)
                }
            }
            .alert(
                "Do you want to delete it?",
                isPresented: $showDeleteConfirm
            ) {
                Button("Delete", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your plant MySnakePlant will be deleted permanently.")
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(isPresented: $showEditPlant) {
                EditPlantView()
            }
        //}
    }

    // MARK: - Watering Card

    private var wateringCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Watering")
                .font(.system(size: 20, weight: .bold))

            Text("Every 3 Days")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Text("200ml")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer(minLength: 14)

            Text("Next:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
            Text("Tomorrow 8:00 AM")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
            Spacer(minLength: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - Feeding Card

    private var feedingCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Feeding")
                .font(.system(size: 20, weight: .bold))

            Text("Every 6 Months")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Text("General fertilizer")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer(minLength: 14)

            Text("Next:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
            Text("January 1, 2026")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
            Spacer(minLength: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - Info Card (Light / Notification / Location)

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack (alignment: .top){
                Text("History")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                NavigationLink {
                    CareHistoryView()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glassProminent)
                .tint(.mint)
            }
            
            Spacer(minLength: 1)

            historyItem(type: "Water:", date: "December 10, 2025", color: .blue)
            Divider()
            historyItem(type: "Feed:", date: "July 2, 2025", color: .orange)
            Divider()
            historyItem(type: "Water:", date: "December 3, 2025", color: .blue)
            
            //Spacer(minLength: 0.1)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    private func historyItem(type: String, date: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(type)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(date)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

#Preview {
    PlantDetailView()
}
