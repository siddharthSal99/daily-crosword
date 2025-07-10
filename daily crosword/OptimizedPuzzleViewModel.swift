import Foundation
import SwiftUI
import Combine

// MARK: - Optimized View Model with Fine-Grained Updates

@MainActor
class OptimizedPuzzleViewModel: ObservableObject {
    @Published private(set) var grid: CrosswordGrid
    @Published var selectedCell: CellPosition?
    @Published var direction: Direction = .across
    @Published private(set) var validationResult: ValidationResult = ValidationResult(
        correctCells: [],
        incorrectCells: [],
        isComplete: false
    )
    
    private var cancellables = Set<AnyCancellable>()
    private let storage: PuzzleStorageProtocol
    let puzzle: PuzzleDetail
    
    init(puzzle: PuzzleDetail, storage: PuzzleStorageProtocol = UserDefaultsPuzzleStorage()) {
        self.puzzle = puzzle
        self.storage = storage
        
        // Load saved state or create new grid
        if let savedGrid = storage.loadGrid(for: puzzle.id) {
            self.grid = CrosswordGrid(grid: savedGrid)
        } else {
            // Initialize with spaces instead of empty strings
            let initialGrid = puzzle.grid.map { $0.map { $0 == "." ? "." : " " } }
            self.grid = CrosswordGrid(grid: initialGrid)
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Debounce validation to avoid excessive computation
        $grid
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validate()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Cell Updates (Fine-Grained)
    
    func updateCell(at position: CellPosition, with value: String) {
        guard let cell = grid[position], !cell.isBlack else { return }
        
        // Update only the specific cell
        grid.updateCell(at: position, with: value)
        
        // Save to storage
        storage.saveCell(position, value: value, for: puzzle.id)
        
        // Trigger objectWillChange for this specific update
        objectWillChange.send()
    }
    
    func selectCell(_ position: CellPosition) {
        guard let cell = grid[position], !cell.isBlack else { return }
        
        if selectedCell == position {
            // Toggle direction if same cell selected
            direction = direction == .across ? .down : .across
        } else {
            selectedCell = position
        }
    }
    
    // MARK: - Navigation
    
    func nextCell(from position: CellPosition) -> CellPosition? {
        switch direction {
        case .across:
            return nextAcrossCell(from: position)
        case .down:
            return nextDownCell(from: position)
        }
    }
    
    func previousCell(from position: CellPosition) -> CellPosition? {
        switch direction {
        case .across:
            return previousAcrossCell(from: position)
        case .down:
            return previousDownCell(from: position)
        }
    }
    
    private func nextAcrossCell(from position: CellPosition) -> CellPosition? {
        let row = position.row
        var col = position.col + 1
        
        while col < grid.dimensions.columns {
            if let cell = grid[row, col], !cell.isBlack {
                return CellPosition(row: row, col: col)
            }
            col += 1
        }
        return nil
    }
    
    private func previousAcrossCell(from position: CellPosition) -> CellPosition? {
        let row = position.row
        var col = position.col - 1
        
        while col >= 0 {
            if let cell = grid[row, col], !cell.isBlack {
                return CellPosition(row: row, col: col)
            }
            col -= 1
        }
        return nil
    }
    
    private func nextDownCell(from position: CellPosition) -> CellPosition? {
        let col = position.col
        var row = position.row + 1
        
        while row < grid.dimensions.rows {
            if let cell = grid[row, col], !cell.isBlack {
                return CellPosition(row: row, col: col)
            }
            row += 1
        }
        return nil
    }
    
    private func previousDownCell(from position: CellPosition) -> CellPosition? {
        let col = position.col
        var row = position.row - 1
        
        while row >= 0 {
            if let cell = grid[row, col], !cell.isBlack {
                return CellPosition(row: row, col: col)
            }
            row -= 1
        }
        return nil
    }
    
    // MARK: - Validation
    
    private func validate() {
        var correctCells: Set<CellPosition> = []
        var incorrectCells: Set<CellPosition> = []
        
        for cell in grid.cells where !cell.isBlack {
            let expectedValue = puzzle.grid[cell.position.row][cell.position.col]
            if cell.value.uppercased() == expectedValue.uppercased() {
                correctCells.insert(cell.position)
            } else if !cell.value.isEmpty {
                incorrectCells.insert(cell.position)
            }
        }
        
        let isComplete = correctCells.count == grid.cells.filter { !$0.isBlack }.count
        
        validationResult = ValidationResult(
            correctCells: correctCells,
            incorrectCells: incorrectCells,
            isComplete: isComplete
        )
    }
    
    // MARK: - Actions
    
    func solve() {
        // Update all cells with correct values
        for cell in grid.cells where !cell.isBlack {
            let correctValue = puzzle.grid[cell.position.row][cell.position.col]
            grid.updateCell(at: cell.position, with: correctValue)
        }
        
        // Save the solved state
        storage.saveGrid(grid.cells.map { $0.value }, for: puzzle.id)
        
        validate()
    }
    
    func clear() {
        // Clear all non-black cells with spaces
        for cell in grid.cells where !cell.isBlack {
            grid.updateCell(at: cell.position, with: " ")
        }
        
        // Save the cleared state
        storage.saveGrid(grid.cells.map { $0.value }, for: puzzle.id)
        
        validationResult = ValidationResult(
            correctCells: [],
            incorrectCells: [],
            isComplete: false
        )
    }
    
    // MARK: - Helper Methods
    
    func getCell(at position: CellPosition) -> CrosswordCell? {
        return grid[position]
    }
    
    func isCellCorrect(at position: CellPosition) -> Bool {
        return validationResult.correctCells.contains(position)
    }
    
    func isCellIncorrect(at position: CellPosition) -> Bool {
        return validationResult.incorrectCells.contains(position)
    }
}

// MARK: - Storage Protocol

protocol PuzzleStorageProtocol {
    func saveCell(_ position: CellPosition, value: String, for puzzleId: String)
    func loadCell(_ position: CellPosition, for puzzleId: String) -> String?
    func saveGrid(_ grid: [String], for puzzleId: String)
    func loadGrid(for puzzleId: String) -> [[String]]?
}

// MARK: - UserDefaults Implementation

class UserDefaultsPuzzleStorage: PuzzleStorageProtocol {
    private let userDefaults = UserDefaults.standard
    
    func saveCell(_ position: CellPosition, value: String, for puzzleId: String) {
        let key = "cell-\(puzzleId)-\(position.row)-\(position.col)"
        userDefaults.set(value, forKey: key)
    }
    
    func loadCell(_ position: CellPosition, for puzzleId: String) -> String? {
        let key = "cell-\(puzzleId)-\(position.row)-\(position.col)"
        return userDefaults.string(forKey: key)
    }
    
    func saveGrid(_ grid: [String], for puzzleId: String) {
        let key = "grid-\(puzzleId)"
        userDefaults.set(grid, forKey: key)
    }
    
    func loadGrid(for puzzleId: String) -> [[String]]? {
        let key = "grid-\(puzzleId)"
        guard let flatGrid = userDefaults.array(forKey: key) as? [String] else {
            return nil
        }
        
        // Convert flat array back to 2D array
        // This assumes we know the dimensions from the original puzzle
        // In a real implementation, you'd store the dimensions too
        return nil // Placeholder - would need puzzle dimensions
    }
} 