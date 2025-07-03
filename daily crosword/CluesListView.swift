import SwiftUI

struct CluesListView: View {
    let clues: PuzzleClues
    let selectedCell: (row: Int, col: Int)?
    let grid: [[String]]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Across")
                .font(.title2).bold()
                .foregroundColor(Color.blue)
                .padding(.vertical, 6)

            ForEach(clues.across.indices, id: \ .self) { i in
                if let clue = clues.across[i] {
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(i).")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        Text(clue)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Spacer(minLength: 24)
            Divider()
                .padding(.vertical, 4)

            Text("Down")
                .font(.title2).bold()
                .foregroundColor(Color.blue)
                .padding(.vertical, 6)

            ForEach(clues.down.indices, id: \ .self) { i in
                if let clue = clues.down[i] {
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(i).")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        Text(clue)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }
} 