//
//  CharacterService.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

protocol CharacterService: Sendable {
    func searchCharacters(named name: String) async throws -> [Character]
}

enum CharacterServiceError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case unexpectedStatus(Int)
}

#if DEBUG
final class CharacterServiceStub: CharacterService {
    var searchResultsToReturn: Result<[Character], Error> = .success([])
    private(set) var searchedNames: [String] = []

    func searchCharacters(named name: String) async throws -> [Character] {
        searchedNames.append(name)
        return try searchResultsToReturn.get()
    }
}
#endif

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
