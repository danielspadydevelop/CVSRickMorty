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

    func searchCharacters(named name: String) async throws -> [Character] {
        try searchResultsToReturn.get()
    }
}
#endif
