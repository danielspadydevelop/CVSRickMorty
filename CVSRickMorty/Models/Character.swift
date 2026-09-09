//
//  Character.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

nonisolated struct Character: Decodable, Equatable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let origin: Origin
    let image: URL
    let created: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        status = try container.decode(String.self, forKey: .status)
        species = try container.decode(String.self, forKey: .species)
        type = try container.decode(String.self, forKey: .type)
        origin = try container.decode(Origin.self, forKey: .origin)
        image = try container.decode(URL.self, forKey: .image)

        let createdString = try container.decode(String.self, forKey: .created)
        do {
            created = try Date(createdString, strategy: .iso8601)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .created,
                in: container,
                debugDescription: "Expected an ISO 8601 date string."
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case species
        case type
        case origin
        case image
        case created
    }
}

nonisolated struct Origin: Decodable, Equatable {
    let name: String
}

nonisolated struct CharacterResponse: Decodable {
    let results: [Character]
}
