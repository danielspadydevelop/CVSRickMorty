//
//  CharacterFilters.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation

enum StatusFilter: String, CaseIterable {
    case any
    case alive
    case dead
    case unknown

    var displayName: String { rawValue.capitalized }
    var queryValue: String? { self == .any ? nil : rawValue }
}

enum SpeciesFilter: String, CaseIterable {
    case any
    case human = "Human"
    case alien = "Alien"
    case humanoid = "Humanoid"
    case robot = "Robot"
    case animal = "Animal"
    case cronenberg = "Cronenberg"
    case disease = "Disease"
    case mythologicalCreature = "Mythological Creature"
    case poopybutthole = "Poopybutthole"
    case planet = "Planet"

    var displayName: String { rawValue.capitalized }
    var queryValue: String? { self == .any ? nil : rawValue }
}
