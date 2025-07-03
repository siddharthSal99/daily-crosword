import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedPuzzle: PuzzleListItem?

    var body: some View {
        NavigationView {
            VStack {
                Text("Puzzles Solved: \(PuzzleViewModel.solvedPuzzlesCount)")
                    .font(.headline)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                SearchBar(text: $viewModel.searchTerm, onSearch: {
                    Task { await viewModel.fetchPuzzles(reset: true) }
                })
                List {
                    ForEach(viewModel.puzzles) { puzzle in
                        Button {
                            selectedPuzzle = puzzle
                        } label: {
                            VStack(alignment: .leading) {
                                Text(puzzle.content.title).font(.headline)
                                Text("By \(puzzle.content.author)").font(.subheadline)
                                Text(puzzle.content.type).font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onAppear {
                            if puzzle == viewModel.puzzles.last, viewModel.hasMore {
                                Task { await viewModel.fetchPuzzles() }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Crossword Puzzles")
                .background(
                    NavigationLink(
                        destination: selectedPuzzle.map { puzzle in
                            PuzzleView(puzzle: convertToPuzzleDetail(puzzle))
                        },
                        isActive: Binding(
                            get: { selectedPuzzle != nil },
                            set: { if !$0 { selectedPuzzle = nil } }
                        )
                    ) { EmptyView() }
                )
            }
            .onAppear { Task { await viewModel.fetchPuzzles(reset: true) } }
        }
    }
    
    // Helper function to convert PuzzleListItem to PuzzleDetail for the solving view
    private func convertToPuzzleDetail(_ puzzleItem: PuzzleListItem) -> PuzzleDetail {
        return PuzzleDetail(
            id: puzzleItem.id,
            name: puzzleItem.content.title,
            date: extractDateFromTitle(puzzleItem.content.title),
            author: puzzleItem.content.author,
            grid: puzzleItem.content.grid,
            clues: puzzleItem.content.clues
        )
    }
    
    // Helper function to extract date from title (e.g., "Minute Cryptic Clue 372: July 2, 2025" -> "July 2, 2025")
    private func extractDateFromTitle(_ title: String) -> String {
        if let colonIndex = title.lastIndex(of: ":") {
            let afterColon = String(title[title.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            return afterColon
        }
        return title // Return full title if no date found
    }
}

// Extension to make PuzzleDetail initializable from our data
extension PuzzleDetail {
    init(id: String, name: String, date: String, author: String, grid: [[String]], clues: PuzzleClues) {
        self.id = id
        self.name = name
        self.date = date
        self.author = author
        self.grid = grid
        self.clues = clues
    }
} 