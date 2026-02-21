//
//  MyGardenView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

private struct StaticPlant: Identifiable {
    let id: Int
    let name: String
    let location: String
    let imageName: String
    let statusText: String
    let statusColor: Color
}

private let staticPlants: [StaticPlant] = [
    StaticPlant(id: 1, name: "Snake Plant", location: "Living Room",
                imageName: "IMG_2411", statusText: "Tomorrow", statusColor: .orange),
    StaticPlant(id: 2, name: "Spider Plant", location: "Bedroom",
                imageName: "IMG_2414", statusText: "Today", statusColor: .blue),
    StaticPlant(id: 3, name: "Succulent", location: "Balcony",
                imageName: "IMG_2412", statusText: "In 6 Days", statusColor: .mint),
    StaticPlant(id: 4, name: "Monstera", location: "Office",
                imageName: "IMG_2413", statusText: "Overdue", statusColor: .red),
]

struct MyGardenView: View {
    @State private var showEmpty = false
    @State private var showAddPlant = false

    init(showEmpty: Bool = false) {
        _showEmpty = State(initialValue: showEmpty)
    }

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

                    if showEmpty {
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
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Rachel's Garden")
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

    private var plantGrid: some View {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(staticPlants) { plant in
                    // Navigate to plant detail on tap
                    NavigationLink {
                        PlantDetailView()
                    } label: {
                        PlantCard(plant: plant)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 80)
        }

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

private struct PlantCard: View {
    let plant: StaticPlant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.12))
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
                .overlay(
                    Image(plant.imageName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .padding(.horizontal, 12)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(plant.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(plant.location)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(plant.statusText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(plant.statusColor)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview("Garden with Cards") {
    MyGardenView(showEmpty: false)
}

#Preview("Empty Garden") {
    MyGardenView(showEmpty: true)
}
