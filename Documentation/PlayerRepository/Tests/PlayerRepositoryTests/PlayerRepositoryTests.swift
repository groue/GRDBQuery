import XCTest
import GRDB
import PlayerRepository

final class PlayerRepositoryTests: XCTestCase {
    func testInsert() throws {
        // Given an empty repo
        let repo = try PlayerRepository(DatabaseQueue())
        
        // When we insert a player
        let insertedPlayer = Player(id: 1, name: "Arthur", score: 1000, photoID: 1)
        try repo.insert(insertedPlayer)
        
        // Then the player is inserted
        let fetchedPlayer = try XCTUnwrap(repo.reader.read(Player.fetchOne))
        XCTAssertEqual(fetchedPlayer, insertedPlayer)
    }
    
    func testUpdate() throws {
        // Given a repo that contains a player
        let repo = try PlayerRepository(DatabaseQueue())
        try repo.insert(Player(id: 1, name: "Arthur", score: 1000, photoID: 1))

        // When we update a player
        let updatedPlayer = Player(id: 1, name: "Barbara", score: 0, photoID: 2)
        try repo.update(updatedPlayer)
        
        // Then the player is updated
        let fetchedPlayer = try XCTUnwrap(repo.reader.read(Player.fetchOne))
        XCTAssertEqual(fetchedPlayer, updatedPlayer)
    }
    
    func test() throws {
        // Given a repo that contains a player
        let repo = try PlayerRepository(DatabaseQueue())
        try repo.insert(Player(id: 1, name: "Arthur", score: 1000, photoID: 1))

        // When we delete all players
        try repo.deleteAllPlayer()
        
        // Then no player exists
        let count = try repo.reader.read(Player.fetchCount(_:))
        XCTAssertEqual(count, 0)
    }
}
