import Foundation
import SwiftUI

// MARK: - Optimized Data Structures

struct CellPosition: Equatable, Hashable {
    let row: Int
    let col: Int
}

struct GridDimensions {
    let rows: Int
    let columns: Int
}

// Core cell data as a struct for better performance
struct CrosswordCell: Equatable, Hashable {
    let position: CellPosition
    var value: String
    let isBlack: Bool
    let clueNumber: Int?
    
    init(row: Int, col: Int, value: String, isBlack: Bool, clueNumber: Int? = nil) {
        self.position = CellPosition(row: row, col: col)
        self.value = value
        self.isBlack = isBlack
        self.clueNumber = clueNumber
    }
}

// Optimized grid structure
struct CrosswordGrid {
    let dimensions: GridDimensions
    private(set) var cells: [CrosswordCell]
    
    init(grid: [[String]]) {
        self.dimensions = GridDimensions(rows: grid.count, columns: grid.first?.count ?? 0)
        self.cells = []
        
        // Convert 2D array to flat array for better cache performance
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                let isBlack = grid[row][col] == "."
                let cell = CrosswordCell(
                    row: row,
                    col: col,
                    value: isBlack ? "." : "",
                    isBlack: isBlack
                )
                cells.append(cell)
            }
        }
        
        // Compute clue numbers
        self.computeClueNumbers()
    }
    
    subscript(row: Int, col: Int) -> CrosswordCell? {
        cells.first { $0.position == CellPosition(row: row, col: col) }
    }
    
    subscript(position: CellPosition) -> CrosswordCell? {
        cells.first { $0.position == position }
    }
    
    mutating func updateCell(at position: CellPosition, with value: String) {
        if let index = cells.firstIndex(where: { $0.position == position }) {
            cells[index].value = value
        }
    }
    
    private mutating func computeClueNumbers() {
        var clueNum = 1
        var clueNumbers: [CellPosition: Int] = [:]
        
        // First pass: identify clue start positions
        for cell in cells where !cell.isBlack {
            let position = cell.position
            let isAcrossStart = isAcrossClueStart(at: position)
            let isDownStart = isDownClueStart(at: position)
            
            if isAcrossStart || isDownStart {
                clueNumbers[position] = clueNum
                clueNum += 1
            }
        }
        
        // Second pass: assign clue numbers to all cells
        for i in 0..<cells.count {
            let position = cells[i].position
            if !cells[i].isBlack {
                let acrossClue = findClueNumber(for: position, direction: .across, clueNumbers: clueNumbers)
                let downClue = findClueNumber(for: position, direction: .down, clueNumbers: clueNumbers)
                cells[i] = CrosswordCell(
                    row: position.row,
                    col: position.col,
                    value: cells[i].value,
                    isBlack: cells[i].isBlack,
                    clueNumber: acrossClue ?? downClue
                )
            }
        }
    }
    
    private func isAcrossClueStart(at position: CellPosition) -> Bool {
        let row = position.row
        let col = position.col
        
        // Check if this is the start of an across word
        let isStart = (col == 0 || self[row, col - 1]?.isBlack == true) &&
                     (col + 1 < dimensions.columns && self[row, col + 1]?.isBlack == false)
        
        return isStart
    }
    
    private func isDownClueStart(at position: CellPosition) -> Bool {
        let row = position.row
        let col = position.col
        
        // Check if this is the start of a down word
        let isStart = (row == 0 || self[row - 1, col]?.isBlack == true) &&
                     (row + 1 < dimensions.rows && self[row + 1, col]?.isBlack == false)
        
        return isStart
    }
    
    private func findClueNumber(for position: CellPosition, direction: Direction, clueNumbers: [CellPosition: Int]) -> Int? {
        let row = position.row
        let col = position.col
        
        switch direction {
        case .across:
            var c = col
            while c > 0 && self[row, c - 1]?.isBlack == false {
                c -= 1
            }
            return clueNumbers[CellPosition(row: row, col: c)]
        case .down:
            var r = row
            while r > 0 && self[r - 1, col]?.isBlack == false {
                r -= 1
            }
            return clueNumbers[CellPosition(row: r, col: col)]
        }
    }
}

enum Direction {
    case across, down
}

struct ValidationResult {
    let correctCells: Set<CellPosition>
    let incorrectCells: Set<CellPosition>
    let isComplete: Bool
}

// Cached clue number computation
final class ClueNumberCache {
    private var cache: [CellPosition: Int] = [:]
    private let grid: CrosswordGrid
    
    init(grid: CrosswordGrid) {
        self.grid = grid
    }
    
    func clueNumber(for position: CellPosition) -> Int? {
        if let cached = cache[position] {
            return cached
        }
        
        // This would be computed based on the grid structure
        // For now, we'll use the cell's clue number
        if let cell = grid[position] {
            cache[position] = cell.clueNumber
            return cell.clueNumber
        }
        
        return nil
    }
} 