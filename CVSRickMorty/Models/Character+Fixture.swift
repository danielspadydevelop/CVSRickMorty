//
//  Character+Fixture.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

#if DEBUG
extension Character {
    static func fixture(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        origin: Origin = Origin(name: "Earth (C-137)"),
        image: URL = URL(fileURLWithPath: "/tmp/avatar.jpeg"),
        created: Date = Date(timeIntervalSince1970: 0)
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            origin: origin,
            image: image,
            created: created
        )
    }
}
#endif
