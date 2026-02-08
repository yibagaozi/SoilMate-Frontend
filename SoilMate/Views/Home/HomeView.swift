//
//  HomeView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

struct HomeView: View {
    private let headerHeight: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    // Today's Tasks Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Tasks")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.green.opacity(0.3))
                                .frame(height: 300)
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green.opacity(0.5))
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Snake Plant")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("Living Room")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Watering needed")
                                            .font(.body)
                                            .fontWeight(.semibold)

                                        Text("200ml · scheduled for 8:00 AM")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
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
                        }
                        .glassEffect(.regular, in: .rect(cornerRadius: 30))
                        .padding(.horizontal)
                    }

                    // Up Next Section
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
                                    VStack(alignment: .leading, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.green.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.green.opacity(0.5))
                                            )

                                        Text("Snake Plant").font(.headline)
                                        Text("Living Room").font(.caption).foregroundColor(.gray)
                                        Text("Tomorrow")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .frame(width: 180, alignment: .leading)
                                    .glassEffect(.regular, in: .rect(cornerRadius: 20))

                                    VStack(alignment: .leading, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.green.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.green.opacity(0.5))
                                            )

                                        Text("Succulent").font(.headline)
                                        Text("Balcony").font(.caption).foregroundColor(.gray)
                                        Text("In 6 Days")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .frame(width: 180, alignment: .leading)
                                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.green.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.green.opacity(0.5))
                                            )

                                        Text("Succulent").font(.headline)
                                        Text("Balcony").font(.caption).foregroundColor(.gray)
                                        Text("In 6 Days")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .frame(width: 180, alignment: .leading)
                                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
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

#Preview {
    HomeView()
}
