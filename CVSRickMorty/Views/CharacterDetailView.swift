//
//  CharacterDetailView.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character

    private let formatter = CharacterDetailFormatter()

    @State private var shareItems: [Any] = []
    @State private var isPreparingShare = false
    @State private var isShowingShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: character.image) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel(character.name)

                VStack(alignment: .leading, spacing: 12) {
                    detailRow(title: "Species", text: character.species)
                    detailRow(title: "Status", text: character.status)
                    detailRow(title: "Origin", text: character.origin.name)
                    if let type = formatter.typeText(for: character) {
                        detailRow(title: "Type", text: type)
                    }
                    detailRow(title: "Created", text: formatter.createdDateText(for: character))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(character.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Share", systemImage: "square.and.arrow.up") {
                    Task { await prepareShare() }
                }
                .disabled(isPreparingShare)
                .accessibilityLabel("Share character")
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(items: shareItems)
                .presentationDetents([.medium, .large])
        }
    }

    private var shareText: String {
        "\(character.name) — \(character.species), \(character.status), "
            + "from \(character.origin.name). "
            + "Created \(formatter.createdDateText(for: character))."
    }

    private func prepareShare() async {
        isPreparingShare = true
        defer { isPreparingShare = false }

        var items: [Any] = [shareText]
        if let data = try? await URLSession.shared.data(from: character.image).0,
           let image = UIImage(data: data) {
            items.insert(image, at: 0)
        }
        shareItems = items
        isShowingShareSheet = true
    }

    private func detailRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundStyle(.secondary)
            Text(text)
        }
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(character: .fixture())
    }
}
