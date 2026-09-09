//
//  CharacterService.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

nonisolated struct CharacterQuery: Equatable {
    var name: String
    var status: String?
    var species: String?
    var type: String?

    init(name: String, status: String? = nil, species: String? = nil, type: String? = nil) {
        self.name = name
        self.status = status
        self.species = species
        self.type = type
    }
}

protocol CharacterService: Sendable {
    func searchCharacters(matching query: CharacterQuery) async throws -> [Character]
}

enum CharacterServiceError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case unexpectedStatus(Int)
}

extension CharacterServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .unexpectedStatus(let statusCode):
            return "The server returned an unexpected status code: \(statusCode)."
        }
    }
}

#if DEBUG
final class CharacterServiceStub: CharacterService {
    var searchResultsToReturn: Result<[Character], Error> = .success([])
    private(set) var receivedQueries: [CharacterQuery] = []

    func searchCharacters(matching query: CharacterQuery) async throws -> [Character] {
        receivedQueries.append(query)
        return try searchResultsToReturn.get()
    }
}
#endif
