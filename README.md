# CVSRickMorty

A SwiftUI iPhone app for searching characters from the [Rick and Morty API](https://rickandmortyapi.com/). Built test-first with Swift concurrency and modern SwiftUI patterns.

## Features

### Search
- Search bar pinned at the top of the list; results update as you type (debounced 300 ms, previous request cancelled on each keystroke)
- Results come from `https://rickandmortyapi.com/api/character/?name=<query>`
- Clearing the field empties the results and returns to the empty state
- Tapping Cancel restores the last saved search; changing filters re-applies them to the last saved search
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
- API errors surface a "Search Failed" message over the list without removing the search bar
- A 404 from the API (no matching characters) maps to the dedicated no-results state

### App icon
Custom green-portal app icon, generated programmatically with CoreGraphics, with dark and tinted variants.

### Accessibility
- VoiceOver labels throughout the list, detail view, and toolbar
- Each list row is a single combined accessibility element; detail rows are combined
- Supports Dynamic Type

## Architecture

Plain SwiftUI with an `@Observable` view model and protocol-based services:

- `CharacterSearchViewModel` — owns search text, filters, loading/error state, and debounces API calls; remembers the last submitted query for Cancel and filter re-applies; cancels in-flight work on deinit
- `CharacterService` protocol — abstracts the API so the view model and views are testable with stubs
- `RickAndMortyAPIService` — builds requests with `URLComponents` and decodes responses with `Codable` models
- `SearchBar` — a `UIViewRepresentable` `UISearchBar` wrapper; SwiftUI's `searchable` cannot distinguish a text clear from a Cancel gesture, while the `UISearchBarDelegate` reports them explicitly
- `CharacterDetailFormatter` — formats the conditional type row and the created date

Networking uses `URLSession` with `async`/`await`; nothing blocks the main thread.

## Testing

- 22 unit tests covering decoding, the search view model (debounce, cancellation, error and no-results states, Cancel restore, filters), the API client, and date/type formatting
- UI test covering the search flow end to end in the simulator

## Requirements

- Xcode 26.3+
- iOS 26.2+
- No third-party dependencies

## Getting started

Open `CVSRickMorty.xcodeproj` in Xcode, select an iPhone simulator, and run. No API key is required.
