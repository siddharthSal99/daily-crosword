import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedPuzzle: PuzzleListItem?

    var body: some View {
        NavigationView {
            VStack {
                // Stylized Title
                Text("Crossword Puzzles")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .accentColor.opacity(0.2), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)

                // Fun Puzzles Solved Capsule
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                    Text("\(PuzzleViewModel.solvedPuzzlesCount)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Solved!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 22)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color.purple, Color.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
                .shadow(color: .accentColor.opacity(0.18), radius: 6, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
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