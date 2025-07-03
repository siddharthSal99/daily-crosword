import SwiftUI

struct CluesListView: View {
    let clues: PuzzleClues
    let selectedCell: (row: Int, col: Int)?
    let grid: [[String]]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Across").bold()
            ForEach(clues.across.indices, id: \ .self) { i in
                if let clue = clues.across[i] {
                    Text("\(i). \(clue)")
                }
            }
            Text("Down").bold()
            ForEach(clues.down.indices, id: \ .self) { i in
                if let clue = clues.down[i] {
                    Text("\(i). \(clue)")
                }
            }
        }
        .padding()
    }
} 