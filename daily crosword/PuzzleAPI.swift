import Foundation

struct PuzzleListResponse: Decodable {
    let puzzles: [PuzzleListItem]
}

class PuzzleAPI {
    static let shared = PuzzleAPI()
    private let baseURL = "https://api.foracross.com/api/puzzle_list"

    func fetchPuzzles(search: String?, page: Int) async throws -> [PuzzleListItem] {
        var urlComponents = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "50"),
            URLQueryItem(name: "filter[nameOrTitleFilter]", value: search ?? ""),
            URLQueryItem(name: "filter[sizeFilter][Mini]", value: "true"),
            URLQueryItem(name: "filter[sizeFilter][Standard]", value: "true")
        ]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        print("[CROSSWORD-API] Fetching puzzles from URL: \(url)")
        let (data, _) = try await URLSession.shared.data(from: url)
        print("[CROSSWORD-API] Received data: \(data.count) bytes")
        do {
            let response = try JSONDecoder().decode(PuzzleListResponse.self, from: data)
            print("[CROSSWORD-API] Decoded \(response.puzzles.count) puzzles")
            return response.puzzles
        } catch {
            print("[CROSSWORD-API] Decoding error: \(error)")
            throw error
        }
    }
} 