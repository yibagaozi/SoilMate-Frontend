//
//  MyGardenView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

struct MyGardenView: View {

    @State private var viewModel = MyGardenViewModel()
    @State private var showAddPlant = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    private let headerHeight: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.isEmpty {
                        emptyState
                    } else {
                        plantGrid
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                addButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
            }
            .sheet(isPresented: $showAddPlant) {
                AddPlantView()
            }
            // Reload after adding a new plant
            .onChange(of: showAddPlant) { _, isPresented in
                if !isPresented {
                    Task { await viewModel.load() }
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("My Garden")
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 300)
            Text("No Plants")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Start by adding a plant")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.7))
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Plant Grid

    private var plantGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.plants) { plant in
                NavigationLink {
                    PlantDetailView(userPlantId: plant.id)
                } label: {
                    PlantCard(
                        plant: plant,
                        status: viewModel.nextCareStatus(plant)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 80)
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button(action: { showAddPlant = true }) {
            Image(systemName: "plus")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .frame(width: 30, height: 40)
        }
        .buttonStyle(.glassProminent)
        .tint(.mint)
    }
}

// MARK: - Plant Card

private struct PlantCard: View {
    let plant: UserPlantDetail
    let status: MyGardenViewModel.CareStatus
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Plant image - square, adapts to card width
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.12))
 
                    if let urlStr = plant.plantImageUrl ?? plant.photoUrl,
                       let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.width)
                                .clipped()
                        } placeholder: {
                            leafPlaceholder
                        }
                    } else {
                        leafPlaceholder
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 12)
            .padding(.top, 12)
 
            VStack(alignment: .leading, spacing: 3) {
                Text(plant.nickname ?? plant.plantName ?? "Plant")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
 
                Text(plant.location ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
 
                Text(status.text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(status.color)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
 
    private var leafPlaceholder: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 30))
            .foregroundColor(.green.opacity(0.5))
    }
}
 

#Preview {
    MyGardenView()
}
