import SwiftUI

struct GridView: View {
    let grid: [[String]]
    @Binding var userGrid: [[String]]
    @Binding var selectedCell: (row: Int, col: Int)?
    var onCellTap: (Int, Int) -> Void
    var incorrectCells: Set<[Int]> = []
    var correctCells: Set<[Int]> = []
    var solvedCells: Set<[Int]> = []

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
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(isBlack ? Color.gray : (isCorrect ? Color.green.opacity(0.5) : (isIncorrect ? Color.red.opacity(0.5) : Color.white)))
                                .frame(width: 32, height: 32)
                                .border(Color.black, width: 1)
                            if !isBlack {
                                TextField("", text: $userGrid[row][col])
                                    .multilineTextAlignment(.center)
                                    .frame(width: 32, height: 32)
                                    .background(Color.clear)
                                    .simultaneousGesture(TapGesture().onEnded { onCellTap(row, col) })
                                if let number = clueNumbers[row][col] {
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
            }
        }
    }
} 