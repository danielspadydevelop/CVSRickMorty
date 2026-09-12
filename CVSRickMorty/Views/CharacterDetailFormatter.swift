//
//  CharacterDetailFormatter.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

nonisolated struct CharacterDetailFormatter {
    func createdDateText(for character: Character, locale: Locale = .autoupdatingCurrent) -> String {
        let style = Date.FormatStyle(date: .long, time: .omitted, locale: locale)
        return character.created.formatted(style)
    }

    func typeText(for character: Character) -> String? {
        let trimmedType = character.type.trimmingCharacters(in: .whitespaces)
        return trimmedType.isEmpty ? nil : trimmedType
    }
}
