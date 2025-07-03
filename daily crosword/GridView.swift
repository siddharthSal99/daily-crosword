import SwiftUI

struct GridView: View {
    let grid: [[String]]
    @Binding var userGrid: [[String]]
    @Binding var selectedCell: (row: Int, col: Int)?
    var onCellTap: (Int, Int) -> Void
    var incorrectCells: Set<[Int]> = []
    var solvedCells: Set<[Int]> = []

    var body: some View {
        VStack(spacing: 2) {
            ForEach(grid.indices, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(grid[row].indices, id: \.self) { col in
                        let isBlack = grid[row][col] == "."
                        ZStack {
                            Rectangle()
                                .fill(isBlack ? Color.gray : Color.white)
                                .frame(width: 32, height: 32)
                                .border(Color.black, width: 1)
                            if !isBlack {
                                TextField("", text: $userGrid[row][col])
                                    .multilineTextAlignment(.center)
                                    .frame(width: 32, height: 32)
                                    .background(Color.clear)
                                    .onTapGesture { onCellTap(row, col) }
                            }
                        }
                    }
                }
            }
        }
    }
} 