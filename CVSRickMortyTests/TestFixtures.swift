//
//  TestFixtures.swift
//  CVSRickMortyTests
//
//  Created by Daniel Spady on 9/12/26.
//

/// JSON payloads shared across test suites so the expected API shape
/// lives in exactly one place.
enum TestFixtures {
    static let characterJSON = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "origin": { "name": "Earth (C-137)", "url": "" },
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """
}
