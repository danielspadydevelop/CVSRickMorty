//
//  CharacterRowView.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import SwiftUI

struct CharacterRowView: View {
    let character: Character
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: character.image) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 56, height: 56)
            .clipShape(.rect(cornerRadius: 8))
            .matchedTransitionSource(id: character.id, in: namespace)

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .bold()
                Text(character.species)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    @Previewable @Namespace var namespace

    CharacterRowView(character: .fixture(), namespace: namespace)
}
