//
//  CharacterTests.swift
//  CVSRickMortyTests
//
//  Created by Daniel Spady on 9/9/26.
//

@testable import CVSRickMorty
import Foundation
import Testing

struct CharacterTests {

    private let validCharacterJSON = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "origin": {
                "name": "Earth (C-137)",
                "url": "https://rickandmortyapi.com/api/location/1"
            },
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "created": "2017-11-04T18:48:46.250Z",
            "gender": "Male",
            "url": "https://rickandmortyapi.com/api/character/1",
            "location": {
                "name": "Citadel of Ricks",
                "url": "https://rickandmortyapi.com/api/location/3"
            },
            "episode": [
                "https://rickandmortyapi.com/api/episode/1"
            ]
        }
        """

    @Test("Decodes a character from API-shaped JSON")
    func decodesCharacter() throws {
        let data = try #require(validCharacterJSON.data(using: .utf8))

        let character = try JSONDecoder().decode(Character.self, from: data)

        #expect(character.id == 1)
        #expect(character.name == "Rick Sanchez")
        #expect(character.status == "Alive")
        #expect(character.species == "Human")
        #expect(character.type.isEmpty)
        #expect(character.origin.name == "Earth (C-137)")
        #expect(character.image.absoluteString == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        let formattedCreated = character.created.formatted(
            Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        )
        #expect(formattedCreated == "2017-11-04T18:48:46.250Z")
    }

    @Test("Decodes a search response wrapper containing results")
    func decodesSearchResponse() throws {
        let json = """
            {
                "info": {
                    "count": 1,
                    "pages": 1,
                    "next": null,
                    "prev": null
                },
                "results": [\(validCharacterJSON)]
            }
            """
        let data = try #require(json.data(using: .utf8))

        let response = try JSONDecoder().decode(CharacterResponse.self, from: data)

        #expect(response.results.count == 1)
        #expect(response.results.first?.name == "Rick Sanchez")
    }

    @Test("Throws when a required field is missing")
    func throwsWhenRequiredFieldIsMissing() throws {
        let json = """
            {
                "id": 1,
                "name": "Rick Sanchez",
                "status": "Alive",
                "species": "Human",
                "type": "",
                "origin": { "name": "Earth (C-137)", "url": "" },
                "created": "2017-11-04T18:48:46.250Z"
            }
            """
        let data = try #require(json.data(using: .utf8))

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Character.self, from: data)
        }
    }

    @Test("Throws when the created date is not ISO 8601")
    func throwsOnInvalidCreatedDate() throws {
        let json = """
            {
                "id": 1,
                "name": "Rick Sanchez",
                "status": "Alive",
                "species": "Human",
                "type": "",
                "origin": { "name": "Earth (C-137)", "url": "" },
                "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                "created": "yesterday"
            }
            """
        let data = try #require(json.data(using: .utf8))

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Character.self, from: data)
        }
    }
}
