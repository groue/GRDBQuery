import Players
import SwiftUI

/// A helper button that creates players in the database
struct CreatePlayerButton: View {
    @Environment(\.playerRepository) private var playerRepository
    private var titleKey: LocalizedStringKey
    
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
    }
    
    var body: some View {
        Button {
            _ = try! playerRepository.insert(Player.makeRandom())
        } label: {
            Label(titleKey, systemImage: "plus")
        }
    }
}

/// A helper button that deletes players in the database
struct DeletePlayersButton: View {
    private enum Mode {
        case delete
        case deleteAfter(() -> Void)
        case deleteBefore(() -> Void)
    }
    
    @Environment(\.playerRepository) private var playerRepository
    private var titleKey: LocalizedStringKey
    private var mode: Mode
    
    /// Creates a button that simply deletes players.
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
        self.mode = .delete
    }
    
    /// Creates a button that deletes players soon after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        after action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.mode = .deleteAfter(action)
    }
    
    /// Creates a button that deletes players immediately after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        before action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.mode = .deleteBefore(action)
    }
    
    var body: some View {
        Button {
            switch mode {
            case .delete:
                _ = try! playerRepository.deleteAllPlayer()
                
            case let .deleteAfter(action):
                action()
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000)
                    try playerRepository.deleteAllPlayer()
                }
                
            case let .deleteBefore(action):
                _ = try! playerRepository.deleteAllPlayer()
                action()
            }
        } label: {
            Label(titleKey, systemImage: "trash")
        }
    }
}

// MARK: - Previews

// For tracking the player count in the preview
import GRDB
import GRDBQuery

#Preview {
    struct PlayerCountRequest: ValueObservationQueryable {
        static var defaultValue: Int { 0 }
        
        func fetch(_ db: Database) throws -> Int {
            try Player.fetchCount(db)
        }
    }
    
    struct Preview: View {
        @Query(PlayerCountRequest())
        var playerCount: Int
        
        var body: some View {
            VStack {
                Text("Number of players: \(playerCount)")
                CreatePlayerButton("Create Player")
                DeletePlayersButton("Delete Players")
            }
            .informationBox()
            .padding()
        }
    }
    
    return Preview()
        .playerRepository(.empty())
}
