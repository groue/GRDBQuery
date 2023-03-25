import GRDB
import GRDBQuery
import PlayerRepository
import SwiftUI

@main
struct QueryDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                // Use the on-disk repository in the application
                .environment(\.playerRepository, .shared)
        }
    }
}

// MARK: - Give SwiftUI access to the player repository
//
// Define a new environment key that grants access to a PlayerRepository.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.
private struct PlayerRepositoryKey: EnvironmentKey {
    /// The default appDatabase is an empty in-memory database of players
    static let defaultValue = PlayerRepository.empty()
}

extension EnvironmentValues {
    var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

// Help some views observe the database with the @Query property wrapper.
// See <https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/gettingstarted>
extension Query where Request.DatabaseContext == PlayerRepository {
    /// Creates a `Query`, given an initial `Queryable` request that
    /// uses `PlayerRepository` as a `DatabaseContext`.
    init(_ request: Request) {
        self.init(request, in: \.playerRepository)
    }
}
