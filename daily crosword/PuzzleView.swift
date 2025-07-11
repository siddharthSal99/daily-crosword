import SwiftUI
import Combine

struct PuzzleView: View {
    @StateObject private var viewModel: PuzzleViewModel
    @FocusState private var isInputFocused: Bool
    @State private var inputLetter: String = ""
    @State private var isKeyboardVisible: Bool = false
    private let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    private let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

    init(puzzle: PuzzleDetail) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzle: puzzle))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Stylized Puzzle Title
                Text(viewModel.puzzle.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.accentColor)
                    .shadow(color: .accentColor.opacity(0.12), radius: 2, x: 0, y: 1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 2)
                    .padding(.horizontal, 16)
                if !viewModel.puzzle.author.isEmpty {
                    Text("by \(viewModel.puzzle.author)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 2)
                }

                // Make the grid fully scrollable in both directions
                ScrollView([.horizontal, .vertical]) {
                    GridView(
                        grid: viewModel.puzzle.grid,
                        userCellGrid: viewModel.userCellGrid,
                        selectedCell: $viewModel.selectedCell,
                        onCellTap: viewModel.selectCell,
                        onLetterInput: { row, col, letter in
                            viewModel.updateCell(row: row, col: col, letter: letter)
                            if let next = viewModel.nextCell(from: CellPosition(row: row, col: col)) {
                                viewModel.selectedCell = next
                            }
                        },
                        onBackspace: { row, col in
                            if let prev = viewModel.previousCell(from: CellPosition(row: row, col: col)) {
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
                }

                // Show clues for selected cell
                if let selected = viewModel.selectedCell {
                    let clues = viewModel.cellToClues[selected.row][selected.col]
                    VStack(alignment: .leading, spacing: 2) {
                        if let acrossNum = clues.across, let acrossText = viewModel.puzzle.clues.across[safe: acrossNum], let text = acrossText {
                            let label = Text("Across (")
                            let number = Text("\(acrossNum)").bold()
                            let colon = Text("): ")
                            let clue = Text(text)
                            let full = label + number + colon + clue
                            Group {
                                full
                                    .font(viewModel.direction == .across ? .title3.bold() : .headline)
                                    .foregroundColor(viewModel.direction == .across ? .accentColor : .primary)
                            }
                        }
                        if let downNum = clues.down, let downText = viewModel.puzzle.clues.down[safe: downNum], let text = downText {
                            let label = Text("Down (")
                            let number = Text("\(downNum)").bold()
                            let colon = Text("): ")
                            let clue = Text(text)
                            let full = label + number + colon + clue
                            Group {
                                full
                                    .font(viewModel.direction == .down ? .title3.bold() : .headline)
                                    .foregroundColor(viewModel.direction == .down ? .accentColor : .primary)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                }

                if !isKeyboardVisible {
                    // Action buttons
                    HStack(spacing: 18) {
                        Button(action: { viewModel.validate() }) {
                            VStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Validate")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .frame(width: 80, height: 60)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.accentColor))
                            .foregroundColor(.white)
                            .shadow(color: Color.accentColor.opacity(0.13), radius: 3, x: 0, y: 1)
                        }
                        Button(action: { viewModel.solve() }) {
                            VStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Solve")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .frame(width: 80, height: 60)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.purple))
                            .foregroundColor(.white)
                            .shadow(color: Color.purple.opacity(0.13), radius: 3, x: 0, y: 1)
                        }
                        Button(action: { viewModel.clear() }) {
                            VStack(spacing: 4) {
                                Image(systemName: "eraser.fill")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Clear")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .frame(width: 80, height: 60)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.gray.opacity(0.7)))
                            .foregroundColor(.white)
                            .shadow(color: Color.gray.opacity(0.13), radius: 3, x: 0, y: 1)
                        }
                    }
                    .padding(.vertical, 12)

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
            }
            .navigationTitle(viewModel.puzzle.name)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(Color(.systemBackground))
            .onDisappear {
                viewModel.saveGridState()
            }
            .onReceive(keyboardWillShow) { _ in isKeyboardVisible = true }
            .onReceive(keyboardWillHide) { _ in isKeyboardVisible = false }
        }
    }
} 
