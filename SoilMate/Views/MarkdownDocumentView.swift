//
//  MarkdownDocumentView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import SwiftUI

/// A reusable view that loads a markdown file from the app bundle
/// and renders a small subset of markdown: H1/H2/H3, bullet lists,
/// bold inline, and paragraphs.
struct MarkdownDocumentView: View {

    let fileName: String   // e.g. "PRIVACY_POLICY" (no extension)
    let title: String      // e.g. "Privacy Policy"

    @State private var blocks: [MarkdownBlock] = []
    @State private var loadFailed: Bool = false

    var body: some View {
        ScrollView {
            if loadFailed {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Document not found")
                        .font(.headline)
                    Text("Could not load \(fileName).md from the app bundle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                        view(for: block)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { load() }
    }

    // MARK: - Loading

    private func load() {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            loadFailed = true
            return
        }
        blocks = MarkdownParser.parse(text)
    }

    // MARK: - Block → View

    @ViewBuilder
    private func view(for block: MarkdownBlock) -> some View {
        switch block {
        case .h1(let text):
            styled(text)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 4)

        case .h2(let text):
            styled(text)
                .font(.system(size: 22, weight: .semibold))
                .padding(.top, 12)
                .padding(.bottom, 2)

        case .h3(let text):
            styled(text)
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 8)
                .padding(.bottom, 2)

        case .paragraph(let text):
            styled(text)
                .font(.system(size: 16))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

        case .bullet(let text):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                styled(text)
                    .font(.system(size: 16))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 4)

        case .spacer:
            Color.clear.frame(height: 4)
        }
    }

    /// Renders inline markdown (bold, italic, links) using AttributedString.
    private func styled(_ raw: String) -> Text {
        if let attributed = try? AttributedString(
            markdown: raw,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }
        return Text(raw)
    }
}

// MARK: - Markdown Model

enum MarkdownBlock {
    case h1(String)
    case h2(String)
    case h3(String)
    case paragraph(String)
    case bullet(String)
    case spacer
}

// MARK: - Tiny line-based parser

enum MarkdownParser {
    static func parse(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var paragraphBuffer: [String] = []

        func flushParagraph() {
            if !paragraphBuffer.isEmpty {
                let joined = paragraphBuffer.joined(separator: " ")
                blocks.append(.paragraph(joined))
                paragraphBuffer.removeAll()
            }
        }

        let lines = text.components(separatedBy: .newlines)

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.isEmpty {
                flushParagraph()
                continue
            }

            if line.hasPrefix("### ") {
                flushParagraph()
                blocks.append(.h3(String(line.dropFirst(4))))
            } else if line.hasPrefix("## ") {
                flushParagraph()
                blocks.append(.h2(String(line.dropFirst(3))))
            } else if line.hasPrefix("# ") {
                flushParagraph()
                blocks.append(.h1(String(line.dropFirst(2))))
            } else if line.hasPrefix("- ") {
                flushParagraph()
                blocks.append(.bullet(String(line.dropFirst(2))))
            } else {
                paragraphBuffer.append(line)
            }
        }

        flushParagraph()
        return blocks
    }
}

#Preview {
    NavigationStack {
        MarkdownDocumentView(fileName: "PRIVACY_POLICY", title: "Privacy Policy")
    }
}
