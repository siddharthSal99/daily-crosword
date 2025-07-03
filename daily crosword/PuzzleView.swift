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
                        onCellTap: { row, col in viewModel.selectCell(row: row, col: col) },
                        onLetterInput: { row, col, letter in
                            viewModel.updateCell(row: row, col: col, letter: letter)
                            if let next = viewModel.nextAcrossCell(from: CellPosition(row: row, col: col)) {
                                viewModel.selectedCell = next
                            }
                        },
                        onBackspace: { row, col in
                            if let prev = viewModel.previousAcrossCell(from: CellPosition(row: row, col: col)) {
                                viewModel.selectedCell = prev
                            }
                        },
                        incorrectCells: viewModel.incorrectCells,
                        correctCells: viewModel.correctCells,
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

                // Show clues for selected cell
                if let selected = viewModel.selectedCell {
                    let clues = viewModel.cellToClues[selected.row][selected.col]
                    VStack(alignment: .leading, spacing: 4) {
                        if let acrossNum = clues.across, let acrossText = viewModel.puzzle.clues.across[safe: acrossNum], let text = acrossText {
                            Text("Across (\(acrossNum)): \(text)")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        if let downNum = clues.down, let downText = viewModel.puzzle.clues.down[safe: downNum], let text = downText {
                            Text("Down (\(downNum)): \(text)")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
