import Foundation
import SwiftUI

@MainActor
class PuzzleViewModel: ObservableObject {
    let puzzle: PuzzleDetail
    @Published var userGrid: [[String]]
    @Published var selectedCell: (row: Int, col: Int)?
    @Published var direction: Direction = .across
    @Published var incorrectCells: Set<[Int]> = []
    @Published var correctCells: Set<[Int]> = []
    @Published var solvedCells: Set<[Int]> = []

    enum Direction { case across, down }

    init(puzzle: PuzzleDetail) {
        self.puzzle = puzzle
        self.userGrid = puzzle.grid.map { $0.map { $0 == "." ? "." : "" } }
    }

    func selectCell(row: Int, col: Int) {
        guard puzzle.grid[row][col] != "." else { return }
        if let selected = selectedCell, selected.row == row && selected.col == col {
            direction = (direction == .across) ? .down : .across
        } else {
            selectedCell = (row, col)
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
} 