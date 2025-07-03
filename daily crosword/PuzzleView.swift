import SwiftUI

struct PuzzleView: View {
    @StateObject private var viewModel: PuzzleViewModel
    @FocusState private var isInputFocused: Bool
    @State private var inputLetter: String = ""

    init(puzzle: PuzzleDetail) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzle: puzzle))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Make the grid fully scrollable in both directions
                ScrollView([.horizontal, .vertical]) {
                    GridView(
                        grid: viewModel.puzzle.grid,
                        userGrid: $viewModel.userGrid,
                        selectedCell: $viewModel.selectedCell,
                        onCellTap: viewModel.selectCell,
                        incorrectCells: viewModel.incorrectCells,
                        solvedCells: viewModel.solvedCells
                    )
                    .padding()
                    .frame(
                        minWidth: min(geometry.size.width, 500),
                        maxWidth: .infinity,
                        minHeight: min(geometry.size.width, 500),
                        maxHeight: .infinity,
                        alignment: .center
                    )
                    // No .clipped()
                }

                // Action buttons
                HStack {
                    Button("Validate") { viewModel.validate() }
                    Button("Solve") { viewModel.solve() }
                    Button("Clear") { viewModel.clear() }
                }
                .padding(.vertical, 8)

                // Clues scrollable below the grid
                ScrollView {
                    CluesListView(
                        clues: viewModel.puzzle.clues,
                        selectedCell: viewModel.selectedCell,
                        grid: viewModel.puzzle.grid
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle(viewModel.puzzle.name)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(Color(.systemBackground))
        }
    }
} 