//
//  CharacterDetailFormatter.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

nonisolated struct CharacterDetailFormatter {
    func createdDateText(for character: Character) -> String {
        character.created.formatted(date: .long, time: .omitted)
    }

    func typeText(for character: Character) -> String? {
        let trimmedType = character.type.trimmingCharacters(in: .whitespaces)
        return trimmedType.isEmpty ? nil : trimmedType
    }
}
