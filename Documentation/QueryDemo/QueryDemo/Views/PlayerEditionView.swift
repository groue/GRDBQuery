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
    
    @Query<PlayerPresenceRequest>
    private var playerPresence: Presence<Player>
    
    @State private var gonePlayerAlertPresented = false
    
    init(id: Int64) {
        _playerPresence = Query(PlayerPresenceRequest(id: id))
    }
    
    var body: some View {
        NavigationView {
            if let player = playerPresence.value {
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
        .alert("Ooops, player is gone.", isPresented: $gonePlayerAlertPresented) {
            Button("Dismiss") { dismiss() }
        }
        .onChange(of: playerPresence.exists, initial: true) { _, playerExists in
            if !playerExists {
                gonePlayerAlertPresented = true
            }
        }
    }
}

/// A @Query request that observes the player in the database
private struct PlayerPresenceRequest: PresenceObservationQueryable {
    var id: Int64
    
    func fetch(_ db: Database) throws -> Player? {
        try Player.fetchOne(db, key: id)
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
