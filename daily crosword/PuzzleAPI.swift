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
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let response = try JSONDecoder().decode(PuzzleListResponse.self, from: data)
            return response.puzzles
        } catch {
            throw error
        }
    }
} 