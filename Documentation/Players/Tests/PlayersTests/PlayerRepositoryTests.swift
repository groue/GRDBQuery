import XCTest
import GRDB
import Players

final class PlayerRepositoryTests: XCTestCase {
    func testInsert() throws {
        // Given a properly configured and empty in-memory repo
        let dbQueue = try DatabaseQueue(configuration: PlayerRepository.makeConfiguration())
        let repo = try PlayerRepository(dbQueue)
        
        // When we insert a player
        let insertedPlayer = try repo.insert(Player(name: "Arthur", score: 1000, photoID: 1))
        
        // Then the inserted player has an id
        XCTAssertNotNil(insertedPlayer.id)
        
        // Then the inserted player exists in the database
        let fetchedPlayer = try XCTUnwrap(repo.reader.read(Player.fetchOne))
        XCTAssertEqual(fetchedPlayer, insertedPlayer)
    }
    
    func testUpdate() throws {
        // Given a properly configured in-memory repo that contains a player
        let dbQueue = try DatabaseQueue(configuration: PlayerRepository.makeConfiguration())
        let repo = try PlayerRepository(dbQueue)
        let insertedPlayer = try repo.insert(Player(name: "Arthur", score: 1000, photoID: 1))

        // When we update a player
        var updatedPlayer = insertedPlayer
        updatedPlayer.name = "Barbara"
        updatedPlayer.score = 0
        updatedPlayer.photoID = 2
        try repo.update(updatedPlayer)
        
        // Then the player is updated
        let fetchedPlayer = try XCTUnwrap(repo.reader.read(Player.fetchOne))
        XCTAssertEqual(fetchedPlayer, updatedPlayer)
    }
    
    func test() throws {
        // Given a properly configured in-memory repo that contains a player
        let dbQueue = try DatabaseQueue(configuration: PlayerRepository.makeConfiguration())
        let repo = try PlayerRepository(dbQueue)
        _ = try repo.insert(Player(name: "Arthur", score: 1000, photoID: 1))

        // When we delete all players
        try repo.deleteAllPlayer()
        
        // Then no player exists
        let count = try repo.reader.read(Player.fetchCount(_:))
        XCTAssertEqual(count, 0)
    }
}
