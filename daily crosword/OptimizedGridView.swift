import SwiftUI

// MARK: - Optimized Grid View with LazyVGrid

struct OptimizedGridView: View {
    @ObservedObject var viewModel: OptimizedPuzzleViewModel
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(32), spacing: 2), 
              count: viewModel.grid.dimensions.columns)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(viewModel.grid.cells, id: \.position) { cell in
                OptimizedCellView(
                    cell: cell,
                    isSelected: viewModel.selectedCell == cell.position,
                    isCorrect: viewModel.isCellCorrect(at: cell.position),
                    isIncorrect: viewModel.isCellIncorrect(at: cell.position),
                    onTap: {
                        viewModel.selectCell(cell.position)
                    },
                    onLetterInput: { letter in
                        viewModel.updateCell(at: cell.position, with: letter)
                        if let next = viewModel.nextCell(from: cell.position) {
                            viewModel.selectedCell = next
                        }
                    },
                    onBackspace: {
                        if let prev = viewModel.previousCell(from: cell.position) {
                            viewModel.selectedCell = prev
                        }
                    }
                )
                .equatable()
            }
        }
        .padding()
    }
}

// MARK: - Optimized Cell View

struct OptimizedCellView: View, Equatable {
    let cell: CrosswordCell
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let onTap: () -> Void
    let onLetterInput: (String) -> Void
    let onBackspace: () -> Void
    
    @State private var cellValue: String = ""
    @FocusState private var isFocused: Bool
    
    static func == (lhs: OptimizedCellView, rhs: OptimizedCellView) -> Bool {
        lhs.cell == rhs.cell &&
        lhs.isSelected == rhs.isSelected &&
        lhs.isCorrect == rhs.isCorrect &&
        lhs.isIncorrect == rhs.isIncorrect
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 32, height: 32)
            
            if !cell.isBlack {
                // Text field for input
                TextField("", text: $cellValue)
                    .multilineTextAlignment(.center)
                    .frame(width: 32, height: 32)
                    .background(Color.clear)
                    .focused($isFocused)
                    .onAppear {
                        cellValue = cell.value.isEmpty ? " " : cell.value
                    }
                    .onChange(of: cell.value) { newValue in
                        cellValue = newValue.isEmpty ? " " : newValue
                    }
                    .onChange(of: isSelected) { selected in
                        if selected {
                            isFocused = true
                        } else {
                            isFocused = false
                        }
                    }
                    .onChange(of: cellValue) { newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                        if trimmed.isEmpty {
                            // Backspace at empty
                            onBackspace()
                            cellValue = " " // Keep space to prevent empty state
                        } else {
                            // Process letter input
                            let lastChar = String(trimmed.last!).uppercased()
                            if cellValue != lastChar {
                                cellValue = lastChar
                                onLetterInput(lastChar)
                            }
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded { onTap() })
                
                // Clue number
                if let number = cell.clueNumber {
                    Text("\(number)")
                        .font(.system(size: 9))
                        .foregroundColor(Color.primary)
                        .shadow(color: Color.black.opacity(0.18), radius: 0.5, x: 0, y: 0.5)
                        .padding(2)
                        .frame(width: 32, height: 32, alignment: .topLeading)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { 
            if !cell.isBlack { 
                onTap() 
            }
        }
    }
    
    private var backgroundColor: Color {
        if cell.isBlack {
            return Color(red: 90/255, green: 36/255, blue: 143/255)
        } else if isCorrect {
            return Color.green.opacity(0.5)
        } else if isIncorrect {
            return Color.red.opacity(0.5)
        } else {
            return Color(.systemGray6)
        }
    }
}

// MARK: - Optimized Puzzle View

struct OptimizedPuzzleView: View {
    @StateObject var viewModel: OptimizedPuzzleViewModel
    @State private var isKeyboardVisible: Bool = false
    
    private let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    private let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    
    init(puzzle: PuzzleDetail) {
        _viewModel = StateObject(wrappedValue: OptimizedPuzzleViewModel(puzzle: puzzle))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Title
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
                
                // Grid
                ScrollView([.horizontal, .vertical]) {
                    OptimizedGridView(viewModel: viewModel)
                        .frame(
                            minWidth: min(geometry.size.width, 500),
                            maxWidth: .infinity,
                            minHeight: min(geometry.size.width, 500),
                            maxHeight: .infinity,
                            alignment: .center
                        )
                }
                
                // Clues
                if let selected = viewModel.selectedCell {
                    CluesView(
                        puzzle: viewModel.puzzle,
                        selectedCell: selected,
                        direction: viewModel.direction
                    )
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                }
                
                // Action buttons
                if !isKeyboardVisible {
                    ActionButtonsView(viewModel: viewModel)
                        .padding(.vertical, 12)
                    
                    // Clues list
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
            .onReceive(keyboardWillShow) { _ in isKeyboardVisible = true }
            .onReceive(keyboardWillHide) { _ in isKeyboardVisible = false }
        }
    }
}

// MARK: - Supporting Views

struct CluesView: View {
    let puzzle: PuzzleDetail
    let selectedCell: CellPosition
    let direction: Direction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // This would show the clues for the selected cell
            // Implementation would depend on your clue mapping logic
            Text("Clues for selected cell")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct ActionButtonsView: View {
    @ObservedObject var viewModel: OptimizedPuzzleViewModel
    
    var body: some View {
        HStack(spacing: 18) {
            Button(action: { /* Validate */ }) {
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
    }
} 