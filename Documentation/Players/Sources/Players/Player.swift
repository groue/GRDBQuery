import GRDB

// Equatable for testability
/// A player.
public struct Player: Codable, Equatable {
    private(set) public var id: Int64?
    public var name: String
    public var score: Int
    public var photoID: Int
    
    public init(
        id: Int64? = nil,
        name: String,
        score: Int,
        photoID: Int)
    {
        self.id = id
        self.name = name
        self.score = score
        self.photoID = photoID
    }
}

extension Player: FetchableRecord, MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
