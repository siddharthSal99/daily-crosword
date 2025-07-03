import Foundation
import SwiftUI

@MainActor
class PuzzleViewModel: ObservableObject {
    let puzzle: PuzzleDetail
    @Published var userGrid: [[String]]
    @Published var selectedCell: CellPosition?
    @Published var direction: Direction = .across
    @Published var incorrectCells: Set<[Int]> = []
    @Published var correctCells: Set<[Int]> = []
    @Published var solvedCells: Set<[Int]> = []
    @Published var cellToClues: [[(across: Int?, down: Int?)]] = []

    enum Direction { case across, down }

    init(puzzle: PuzzleDetail) {
        self.puzzle = puzzle
        self.userGrid = puzzle.grid.map { $0.map { $0 == "." ? "." : "" } }
        self.cellToClues = PuzzleViewModel.computeCellClueMap(grid: puzzle.grid)
    }

    static func computeCellClueMap(grid: [[String]]) -> [[(across: Int?, down: Int?)]] {
        var clueNumbers = Array(
            repeating: Array(repeating: Optional<Int>.none, count: grid.first?.count ?? 0),
            count: grid.count
        )
        var clueNum = 1
        for row in grid.indices {
            for col in grid[row].indices {
                if grid[row][col] == "." { continue }
                let isAcrossStart = (col == 0 || grid[row][col-1] == ".") && (col + 1 < grid[row].count && grid[row][col+1] != ".")
                let isDownStart = (row == 0 || grid[row-1][col] == ".") && (row + 1 < grid.count && grid[row+1][col] != ".")
                if isAcrossStart || isDownStart {
                    clueNumbers[row][col] = clueNum
                    clueNum += 1
                }
            }
        }
        var result = Array(
            repeating: Array(repeating: (across: Optional<Int>.none, down: Optional<Int>.none), count: grid.first?.count ?? 0),
            count: grid.count
        )
        for row in grid.indices {
            for col in grid[row].indices {
                if grid[row][col] == "." { continue }
                var c = col
                while c > 0 && grid[row][c-1] != "." { c -= 1 }
                let acrossClue = clueNumbers[row][c]
                var r = row
                while r > 0 && grid[r-1][col] != "." { r -= 1 }
                let downClue = clueNumbers[r][col]
                result[row][col] = (across: acrossClue, down: downClue)
            }
        }
        return result
    }

    func selectCell(row: Int, col: Int) {
        guard puzzle.grid[row][col] != "." else { return }
        let newCell = CellPosition(row: row, col: col)
        if let selected = selectedCell, selected == newCell {
            direction = (direction == .across) ? .down : .across
        } else {
            selectedCell = newCell
        }
        let clues = cellToClues[row][col]
        if let acrossNum = clues.across, let acrossText = puzzle.clues.across[safe: acrossNum] {
            print("Across clue (\(acrossNum)): \(acrossText ?? "")")
        }
        if let downNum = clues.down, let downText = puzzle.clues.down[safe: downNum] {
            print("Down clue (\(downNum)): \(downText ?? "")")
        }
    }

    func updateCell(row: Int, col: Int, letter: String) {
        guard puzzle.grid[row][col] != "." else { return }
        userGrid[row][col] = letter
    }

    func validate() {
        incorrectCells = []
        correctCells = []
        for row in 0..<puzzle.grid.count {
            for col in 0..<puzzle.grid[row].count {
                if puzzle.grid[row][col] != "." {
                    if userGrid[row][col].uppercased() == puzzle.grid[row][col].uppercased() {
                        correctCells.insert([row, col])
                    } else {
                        incorrectCells.insert([row, col])
                    }
                }
            }
        }
    }

    func solve() {
        userGrid = puzzle.grid
        validate()
        solvedCells = Set((0..<puzzle.grid.count).flatMap { row in (0..<puzzle.grid[row].count).map { [row, $0] } })
    }

    func clear() {
        userGrid = puzzle.grid.map { $0.map { $0 == "." ? "." : "" } }
        incorrectCells = []
        correctCells = []
        solvedCells = []
    }

    func nextAcrossCell(from cell: CellPosition) -> CellPosition? {
        let row = cell.row
        let col = cell.col
        var nextCol = col + 1
        while nextCol < puzzle.grid[row].count {
            if puzzle.grid[row][nextCol] != "." {
                return CellPosition(row: row, col: nextCol)
            }
            nextCol += 1
        }
        return nil
    }

    func previousAcrossCell(from cell: CellPosition) -> CellPosition? {
        let row = cell.row
        let col = cell.col
        var prevCol = col - 1
        while prevCol >= 0 {
            if puzzle.grid[row][prevCol] != "." {
                return CellPosition(row: row, col: prevCol)
            }
            prevCol -= 1
        }
        return nil
    }

    func nextCell(from cell: CellPosition) -> CellPosition? {
        switch direction {
        case .across:
            return nextAcrossCell(from: cell)
        case .down:
            return nextDownCell(from: cell)
        }
    }

    func previousCell(from cell: CellPosition) -> CellPosition? {
        switch direction {
        case .across:
            return previousAcrossCell(from: cell)
        case .down:
            return previousDownCell(from: cell)
        }
    }

    func nextDownCell(from cell: CellPosition) -> CellPosition? {
        let row = cell.row
        let col = cell.col
        var nextRow = row + 1
        while nextRow < puzzle.grid.count {
            if puzzle.grid[nextRow][col] != "." {
                return CellPosition(row: nextRow, col: col)
            }
            nextRow += 1
        }
        return nil
    }

    func previousDownCell(from cell: CellPosition) -> CellPosition? {
        let row = cell.row
        let col = cell.col
        var prevRow = row - 1
        while prevRow >= 0 {
            if puzzle.grid[prevRow][col] != "." {
                return CellPosition(row: prevRow, col: col)
            }
            prevRow -= 1
        }
        return nil
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 