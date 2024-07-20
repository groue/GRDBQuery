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
    fileprivate(set) var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

extension View {
    /// Sets both the `playerRepository` (for writes) and `databaseContext`
    /// (for `@Query`) environment values.
    func playerRepository(_ repository: PlayerRepository) -> some View {
        self
            .environment(\.playerRepository, repository)
            .databaseContext(.readOnly { repository.reader })
    }
}
