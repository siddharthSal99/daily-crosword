import Foundation

struct PuzzleListItem: Identifiable, Decodable, Equatable {
    let id: String
    let content: PuzzleContent
    
    enum CodingKeys: String, CodingKey {
        case id = "pid"
        case content
    }
}

struct PuzzleContent: Decodable, Equatable {
    let title: String
    let author: String
    let type: String
    let description: String
    let grid: [[String]]
    let clues: PuzzleClues
    
    enum CodingKeys: String, CodingKey {
        case grid, clues
        case info
    }
    
    enum InfoKeys: String, CodingKey {
        case title, author, type, description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        grid = try container.decode([[String]].self, forKey: .grid)
        clues = try container.decode(PuzzleClues.self, forKey: .clues)
        let info = try container.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        title = try info.decode(String.self, forKey: .title)
        author = try info.decode(String.self, forKey: .author)
        type = try info.decode(String.self, forKey: .type)
        description = try info.decode(String.self, forKey: .description)
    }
}

// Model for the puzzle solving view (when we fetch individual puzzle details)
struct PuzzleDetail: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let date: String
    let author: String
    let grid: [[String]]
    let clues: PuzzleClues

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, grid, clues
        case info
    }
    enum InfoKeys: String, CodingKey {
        case date, author
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        grid = try container.decode([[String]].self, forKey: .grid)
        clues = try container.decode(PuzzleClues.self, forKey: .clues)
        let info = try container.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        date = try info.decode(String.self, forKey: .date)
        author = try info.decode(String.self, forKey: .author)
    }
}

struct PuzzleClues: Decodable, Equatable {
    let across: [String?]
    let down: [String?]
} 
