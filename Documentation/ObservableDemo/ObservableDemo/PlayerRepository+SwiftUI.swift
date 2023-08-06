import GRDBQuery
import Players
import SwiftUI

// MARK: - Give SwiftUI access to the player repository

// Define a new environment key that grants access to a `PlayerRepository`.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.
private struct PlayerRepositoryKey: EnvironmentKey {
    /// The default appDatabase is an empty in-memory repository.
    static let defaultValue = PlayerRepository.empty()
}

extension EnvironmentValues {
    var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

// MARK: - @Query convenience

// Help views and previews observe the database with the @Query property wrapper.
// See <https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/gettingstarted>
extension Query where Request.DatabaseContext == PlayerRepository {
    /// Creates a `Query`, given an initial `Queryable` request that
    /// uses `PlayerRepository` as a `DatabaseContext`.
    init(_ request: Request) {
        self.init(request, in: \.playerRepository)
    }
}
