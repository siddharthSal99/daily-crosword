import SwiftUI

struct CellPosition: Equatable, Hashable {
    let row: Int
    let col: Int
}

struct GridView: View {
    let grid: [[String]]
    @Binding var userGrid: [[String]]
    @Binding var selectedCell: CellPosition?
    var onCellTap: (Int, Int) -> Void
    var onLetterInput: ((Int, Int, String) -> Void)? = nil
    var incorrectCells: Set<[Int]> = []
    var correctCells: Set<[Int]> = []
    var solvedCells: Set<[Int]> = []

    // Per-cell focus
    @FocusState private var focusedCell: CellPosition?

    // Compute clue numbers for each cell
    private var clueNumbers: [[Int?]] {
        var numbers = Array(repeating: Array(repeating: Optional<Int>.none, count: grid.first?.count ?? 0), count: grid.count)
        var clueNum = 1
        for row in grid.indices {
            for col in grid[row].indices {
                if grid[row][col] == "." { continue }
                let isAcrossStart = (col == 0 || grid[row][col-1] == ".") && (col + 1 < grid[row].count && grid[row][col+1] != ".")
                let isDownStart = (row == 0 || grid[row-1][col] == ".") && (row + 1 < grid.count && grid[row+1][col] != ".")
                if isAcrossStart || isDownStart {
                    numbers[row][col] = clueNum
                    clueNum += 1
                }
            }
        }
        return numbers
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(grid.indices, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(grid[row].indices, id: \.self) { col in
                        let isBlack = grid[row][col] == "."
                        let isCorrect = correctCells.contains([row, col])
                        let isIncorrect = incorrectCells.contains([row, col])
                        let clueNumber = clueNumbers[row][col]
                        GridCellView(
                            row: row,
                            col: col,
                            isBlack: isBlack,
                            isCorrect: isCorrect,
                            isIncorrect: isIncorrect,
                            clueNumber: clueNumber,
                            text: $userGrid[row][col],
                            selectedCell: $selectedCell,
                            focusedCell: _focusedCell,
                            onCellTap: onCellTap,
                            onLetterInput: onLetterInput
                        )
                    }
                }
            }
        }
    }
}

// MARK: - GridCellView
struct GridCellView: View {
    let row: Int
    let col: Int
    let isBlack: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let clueNumber: Int?
    @Binding var text: String
    @Binding var selectedCell: CellPosition?
    @FocusState var focusedCell: CellPosition?
    var onCellTap: (Int, Int) -> Void
    var onLetterInput: ((Int, Int, String) -> Void)?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(isBlack ? Color.gray : (isCorrect ? Color.green.opacity(0.5) : (isIncorrect ? Color.red.opacity(0.5) : Color.white)))
                .frame(width: 32, height: 32)
            if !isBlack {
                let cellFocus = CellPosition(row: row, col: col)
                TextField("", text: $text)
                    .multilineTextAlignment(.center)
                    .frame(width: 32, height: 32)
                    .background(Color.clear)
                    .focused($focusedCell, equals: cellFocus)
                    .onChange(of: selectedCell) { newSelected in
                        let shouldFocus: Bool
                        if let sel = newSelected {
                            shouldFocus = (sel.row == row && sel.col == col)
                        } else {
                            shouldFocus = false
                        }
                        if shouldFocus {
                            focusedCell = cellFocus
                        }
                    }
                    .onChange(of: text) { newValue in
                        let lastChar = newValue.last.map { String($0).uppercased() } ?? ""
                        if text != lastChar {
                            text = lastChar
                        }
                        onLetterInput?(row, col, lastChar)
                    }
                    .simultaneousGesture(TapGesture().onEnded { onCellTap(row, col) })
                if let number = clueNumber {
                    Text("\(number)")
                        .font(.system(size: 9))
                        .foregroundColor(.black)
                        .padding(2)
                        .frame(width: 32, height: 32, alignment: .topLeading)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if !isBlack { onCellTap(row, col) } }
    }
} 