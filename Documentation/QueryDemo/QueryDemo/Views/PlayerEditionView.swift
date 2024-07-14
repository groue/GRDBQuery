import Combine
import GRDB
import GRDBQuery
import Players
import SwiftUI

/// The sheet for player edition.
///
/// In this demo app, this view don't want to remain on screen
/// whenever the edited player no longer exists in the database.
struct PlayerEditionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query<PlayerRequest>
    private var player: Player?
    
    @State private var playerPresence: PlayerPresence = .missing
    @State private var gonePlayerAlertPresented = false
    
    init(id: Int64) {
        _player = Query(PlayerRequest(id: id))
    }
    
    var body: some View {
        NavigationView {
            if let player = playerPresence.player {
                VStack {
                    PlayerFormView(player: player)
                    
                    Spacer()
                    
                    if playerPresence.exists {
                        VStack(spacing: 10) {
                            Text("What if another application component deletes the player at the most unexpected moment?")
                                .informationStyle()
                            DeletePlayersButton("Delete Player")
                        }
                        .informationBox()
                    }
                }
                .padding(.horizontal)
                .navigationTitle(player.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { dismiss() }
                    }
                }
            } else {
                PlayerNotFoundView()
            }
        }
        .onChange(of: player, initial: true) {
            if let player {
                playerPresence = .existing(player)
            } else if let oldPlayer = playerPresence.player {
                playerPresence = .gone(oldPlayer)
                gonePlayerAlertPresented = true
            } else {
                gonePlayerAlertPresented = true
            }
        }
        .alert("Ooops, player is gone.", isPresented: $gonePlayerAlertPresented, actions: {
            Button("Dismiss") { dismiss() }
        })
    }
}

/// A @Query request that observes the player (any player, actually) in the database
private struct PlayerRequest: ValueObservationQueryable {
    static var defaultValue: Player? { nil }
    var id: Int64
    
    func fetch(_ db: Database) throws -> Player? {
        try Player.fetchOne(db, key: id)
    }
}

// We handle three distinct cases regarding the presence of the
// edited player:
private enum PlayerPresence {
    /// The player exists in the database
    case existing(Player)
    
    /// Player no longer exists, but we have its latest value.
    case gone(Player)
    
    /// Player does not exist, and we don't have any information about it.
    case missing
    
    var player: Player? {
        switch self {
        case let .existing(player), let .gone(player):
            return player
        case .missing:
            return nil
        }
    }
    
    var exists: Bool {
        switch self {
        case .existing:
            return true
        case .gone, .missing:
            return false
        }
    }
}

// MARK: - Previews

#Preview("Existing player") {
    PlayerEditionView(id: 1)
        .playerRepository(.populated(playerId: 1))
}

#Preview("Missing player") {
    PlayerEditionView(id: -1)
        .playerRepository(.empty())
}
