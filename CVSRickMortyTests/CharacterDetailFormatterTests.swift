//
//  CharacterDetailFormatterTests.swift
//  CVSRickMortyTests
//
//  Created by Daniel Spady on 9/9/26.
//

@testable import CVSRickMorty
import Foundation
import Testing

struct CharacterDetailFormatterTests {

    private let formatter = CharacterDetailFormatter()

    @Test("Formats the created date as a long date without a time")
    func formatsCreatedDate() throws {
        let components = DateComponents(year: 2017, month: 11, day: 4)
        let created = try #require(Calendar.current.date(from: components))
        let character = Character.fixture(created: created)

        #expect(formatter.createdDateText(for: character) == "November 4, 2017")
    }

    @Test("Returns the type text when the character has a type")
    func returnsTypeTextWhenPresent() {
        let character = Character.fixture(type: "Genetic experiment")

        #expect(formatter.typeText(for: character) == "Genetic experiment")
    }

    @Test("Returns nil for the type when the character has none")
    func returnsNilTypeWhenAbsent() {
        let character = Character.fixture(type: "")

        #expect(formatter.typeText(for: character) == nil)
    }
}
