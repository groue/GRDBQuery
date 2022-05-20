import GRDB

extension AppDatabase {
    /// Returns an empty in-memory database.
    static func empty() -> AppDatabase {
        try! AppDatabase(DatabaseQueue())
    }
    
    /// Returns an in-memory database that contains one player.
    ///
    /// - parameter playerId: The ID of the inserted player.
    static func populated(playerId: Int64? = nil) -> AppDatabase {
        let dbManager = self.empty()
        try! dbManager.insert(Player.makeRandom(id: playerId))
        return dbManager
    }
}
