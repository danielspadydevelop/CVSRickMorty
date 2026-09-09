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

    func searchCharacters(matching query: CharacterQuery) async throws -> [Character] {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")
        var queryItems = [URLQueryItem(name: "name", value: query.name)]
        if let status = query.status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        if let species = query.species {
            queryItems.append(URLQueryItem(name: "species", value: species))
        }
        if let type = query.type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        components?.queryItems = queryItems
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
