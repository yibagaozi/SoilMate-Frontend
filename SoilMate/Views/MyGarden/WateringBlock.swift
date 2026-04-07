//
//  WateringBlock.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import SwiftUI
 
struct WateringBlock: View {
    let baseAmountMl: Int
    let calculatedAmountMl: Int
    let tags: [String]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How to Water")
                    .font(.system(size: 16, weight: .bold))
                Text("Allow soil to dry between waterings. Water slowly until it drains from the bottom.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
 
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Suggested today")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                Text("~ ")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Text("\(calculatedAmountMl)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: calculatedAmountMl)
                Text("ml")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
 
            if calculatedAmountMl != baseAmountMl {
                Text("Base \(baseAmountMl) ml adjusted for pot, environment, and season")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
 
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
 
            Text("Region: \(WateringCalculator.currentRegion.displayName). Change in Settings.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
 
// MARK: - Reusable Pot Size Selector
 
struct PotSizeSelector: View {
    @Binding var selection: PotSize
 
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PotSize.allCases, id: \.self) { size in
                Button {
                    selection = size
                } label: {
                    Text(size.displayCode)
                        .font(.system(size: 14, weight: selection == size ? .semibold : .regular))
                        .foregroundColor(selection == size ? .white : .secondary)
                        .frame(width: 36, height: 30)
                        .background(selection == size ? Color.mint : Color.clear)
                }
                .buttonStyle(.plain)
 
                if size != PotSize.allCases.last {
                    Divider().frame(height: 20)
                }
            }
        }
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
 
// MARK: - Pot Size Info Popover Content
 
struct PotSizeInfoPopover: View {
    let selectedSize: PotSize
 
    private struct Entry {
        let size: PotSize
        let label: String
        let description: String
    }
 
    private let guide: [Entry] = [
        Entry(size: .small,      label: "Small  (< 15 cm)",      description: "Fits in one hand. Ideal for seedlings, succulents, and small herbs."),
        Entry(size: .medium,     label: "Medium (15-25 cm)",     description: "Standard nursery pot. Suits most common houseplants."),
        Entry(size: .large,      label: "Large  (25-40 cm)",     description: "Wide opening. Good for tropical foliage and bushy ferns."),
        Entry(size: .extraLarge, label: "Extra Large (> 40 cm)", description: "Floor-standing planter. Built for large trees."),
    ]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pot Size Guide")
                .font(.system(size: 15, weight: .semibold))
                .padding(.bottom, 2)
 
            Text("Sizes refer to the pot's opening diameter.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
 
            ForEach(guide, id: \.size) { entry in
                HStack(alignment: .top, spacing: 12) {
                    Text(entry.size.displayCode)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(selectedSize == entry.size ? Color.mint : Color(.systemGray3))
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
                .padding(.bottom, entry.size == .extraLarge ? 0 : 10)
            }
        }
        .padding(18)
        .frame(width: 280)
        .presentationCompactAdaptation(.popover)
    }
}
 
