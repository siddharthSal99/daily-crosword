import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var puzzles: [PuzzleDetail] = []
    @Published var searchTerm: String = ""
    @Published var isLoading = false
    @Published var page = 1
    @Published var hasMore = true

    func fetchPuzzles(reset: Bool = false) async {
        print("[CROSSWORD-VM] fetchPuzzles called. reset=\(reset), searchTerm=\(searchTerm), page=\(page)")
        if isLoading { print("[CROSSWORD-VM] Already loading, returning early"); return }
        isLoading = true
        print("[CROSSWORD-VM] Loading started")
        if reset {
            page = 1
            puzzles = []
            hasMore = true
            print("[CROSSWORD-VM] Resetting page and puzzles")
        }
        do {
            let newPuzzles = try await PuzzleAPI.shared.fetchPuzzles(search: searchTerm, page: page)
            print("[CROSSWORD-VM] API returned \(newPuzzles.count) puzzles")
            if newPuzzles.isEmpty {
                hasMore = false
                print("[CROSSWORD-VM] No more puzzles to load")
            } else {
                puzzles += newPuzzles
                page += 1
                print("[CROSSWORD-VM] Total puzzles loaded: \(puzzles.count)")
            }
        } catch {
            print("[CROSSWORD-VM] Error fetching puzzles: \(error)")
        }
        isLoading = false
        print("[CROSSWORD-VM] Loading ended")
    }
} 