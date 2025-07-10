import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var puzzles: [PuzzleListItem] = []
    @Published var searchTerm: String = ""
    @Published var isLoading = false
    @Published var page = 0
    @Published var hasMore = true

    func fetchPuzzles(reset: Bool = false) async {
        if isLoading { return }
        isLoading = true
        if reset {
            page = 0
            puzzles = []
            hasMore = true
        }
        do {
            let newPuzzles = try await PuzzleAPI.shared.fetchPuzzles(search: searchTerm, page: page)
            if newPuzzles.isEmpty {
                hasMore = false
            } else {
                puzzles += newPuzzles
                page += 1
            }
        } catch {
            // Handle error silently or log to analytics
        }
        isLoading = false
    }
} 