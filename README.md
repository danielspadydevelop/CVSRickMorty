# CVSRickMorty

A SwiftUI iPhone app for searching characters from the [Rick and Morty API](https://rickandmortyapi.com/). Built test-first with Swift concurrency and modern SwiftUI patterns.

## Features

### Search
- Search bar at the top of the list; results update as you type (debounced 300 ms, previous request cancelled on each keystroke)
- Results come from `https://rickandmortyapi.com/api/character/?name=<query>`
- Loading indicator overlays the list without blocking the UI

### Character list
- Each row shows the character's name, species, and image
- Empty state prompts the user to search; a "No Results" state appears when the API returns none

### Character detail
Tapping a character (or its image) presents a detail view with:
- Name in the navigation title
- Full-width character image with an animated zoom transition from the list
- Species, status, and origin
- Type, shown only when the API provides one
- Created date, formatted for display
- Share button that shares the character image and a metadata summary

### Filters
Filter results by status, species, and type from the filter sheet.

### Error handling
- API errors surface a "Search Failed" message instead of failing silently
- A 404 from the API (no matching characters) maps to the dedicated no-results state

### Accessibility
- VoiceOver labels throughout the list, detail view, and toolbar
- Combined accessibility elements for detail rows
- Supports Dynamic Type

## Architecture

Plain SwiftUI with an `@Observable` view model and protocol-based services:

- `CharacterSearchViewModel` — owns search text, filters, loading/error state, and debounces API calls; cancels in-flight work on deinit
- `CharacterService` protocol — abstracts the API so the view model and views are testable with stubs
- `RickAndMortyAPIService` — builds requests with `URLComponents` and decodes responses with `Codable` models
- `CharacterDetailFormatter` — formats the conditional type row and the created date

Networking uses `URLSession` with `async`/`await`; nothing blocks the main thread.

## Testing

- 18 unit tests covering decoding, the search view model (debounce, cancellation, error and no-results states, filters), and date/type formatting
- UI test covering the search flow end to end in the simulator

## Requirements

- Xcode 26.3+
- iOS 26.2+
- No third-party dependencies

## Getting started

Open `CVSRickMorty.xcodeproj` in Xcode, select an iPhone simulator, and run. No API key is required.
