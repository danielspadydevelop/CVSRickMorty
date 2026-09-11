//
//  SearchBar.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/11/26.
//

import SwiftUI
import UIKit

/// A `UISearchBar` wrapper that reports text, clear, and cancel gestures explicitly.
///
/// SwiftUI's `searchable` does not expose which control changed the search text,
/// so tapping Clear and tapping Cancel produce indistinguishable state changes.
/// The `UISearchBarDelegate` reports them as distinct events, which lets the
/// view model treat clearing (show the empty state) and canceling (restore the
/// last saved search) differently.
struct SearchBar: UIViewRepresentable {
    let text: String
    let prompt: String
    let onTextChange: (String) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextChange: onTextChange, onCancel: onCancel)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = prompt
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search
        searchBar.backgroundColor = .clear
        searchBar.text = text
        return searchBar
    }

    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        guard searchBar.text != text else { return }
        context.coordinator.isProgrammaticUpdate = true
        searchBar.text = text
        context.coordinator.isProgrammaticUpdate = false
    }

    @MainActor
    final class Coordinator: NSObject, UISearchBarDelegate {
        let onTextChange: (String) -> Void
        let onCancel: () -> Void
        var isProgrammaticUpdate = false
        var isEditingText = false

        init(onTextChange: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
            self.onTextChange = onTextChange
            self.onCancel = onCancel
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            guard !isProgrammaticUpdate else { return }
            // Canceling can clear the text after editing ends; ignore that
            // system-driven emptying so the restored search survives.
            guard isEditingText || !searchText.isEmpty else { return }
            onTextChange(searchText)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // resignFirstResponder is unreliable here; endEditing guarantees the
            // editing session closes so the Cancel button actually goes away.
            searchBar.endEditing(true)
            isEditingText = false
            searchBar.showsCancelButton = false
            onCancel()
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }

        // UIKit only delivers cancel-button taps when it manages showsCancelButton
        // itself, so toggle it with the editing state instead of setting it once.
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isEditingText = true
            searchBar.showsCancelButton = true
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            isEditingText = false
            searchBar.showsCancelButton = false
        }
    }
}
