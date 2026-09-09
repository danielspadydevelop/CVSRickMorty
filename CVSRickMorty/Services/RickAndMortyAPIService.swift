//
//  RickAndMortyAPIService.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

nonisolated struct RickAndMortyAPIService: CharacterService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchCharacters(named name: String) async throws -> [Character] {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")
        components?.queryItems = [URLQueryItem(name: "name", value: name)]
        guard let url = components?.url else {
            throw CharacterServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CharacterServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw CharacterServiceError.unexpectedStatus(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(CharacterResponse.self, from: data).results
    }
}
