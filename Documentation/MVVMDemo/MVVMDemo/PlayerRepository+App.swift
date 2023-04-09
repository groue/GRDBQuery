import Foundation
import GRDB
import Players

// A `PlayerRepository` extension for creating various repositories for the
// app, tests, and previews.
extension PlayerRepository {
    /// The on-disk repository for the application.
    static let shared = makeShared()
    
    /// Returns an on-disk repository for the application.
    private static func makeShared() -> PlayerRepository {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
            //
            // Create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(
                path: databaseURL.path,
                // Use default PlayerRepository configuration
                configuration: PlayerRepository.makeConfiguration())

            // Create the PlayerRepository
            let playerRepository = try PlayerRepository(dbPool)
            
            return playerRepository
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Returns an empty in-memory repository, for previews and tests.
    static func empty() -> PlayerRepository {
        try! PlayerRepository(DatabaseQueue(configuration: PlayerRepository.makeConfiguration()))
    }
    
    /// Returns an in-memory repository that contains one player,
    /// for previews and tests.
    ///
    /// - parameter playerId: The ID of the inserted player.
    static func populated(playerId: Int64? = nil) -> PlayerRepository {
        let repo = self.empty()
        _ = try! repo.insert(Player.makeRandom(id: playerId))
        return repo
    }
}
