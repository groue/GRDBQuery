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
    private var playerPresence: PlayerPresence
    
    @State var gonePlayerAlertPresented = false
    
    init(id: Int64) {
        _playerPresence = Query(PlayerPresenceRequest(id: id))
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
        .alert("Ooops, player is gone.", isPresented: $gonePlayerAlertPresented, actions: {
            Button("Dismiss") { dismiss() }
        })
        .onAppear {
            if !playerPresence.exists {
                gonePlayerAlertPresented = true
            }
        }
        .onChange(of: playerPresence.exists, perform: { playerExists in
            if !playerExists {
                gonePlayerAlertPresented = true
            }
        })
    }
}

/// A @Query request that observes the presence of the player in the database.
private struct PlayerPresenceRequest: Queryable {
    static var defaultValue: PlayerPresence { .missing }
    
    var id: Int64
    
    func publisher(in playerRepository: PlayerRepository) -> AnyPublisher<PlayerPresence, Error> {
        ValueObservation
            .tracking(Player.filter(key: id).fetchOne)
            .publisher(in: playerRepository.reader, scheduling: .immediate)
            // Use scan in order to detect the three cases of player presence
            .scan(.missing) { (previous, player) in
                if let player {
                    return .existing(player)
                } else if let player = previous.player {
                    return .gone(player)
                } else {
                    return .missing
                }
            }
            .eraseToAnyPublisher()
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

struct PlayerEditionView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerEditionView(id: 1)
            .environment(\.playerRepository, .populated(playerId: 1))
            .previewDisplayName("Existing player")
        
        PlayerEditionView(id: -1)
            .environment(\.playerRepository, .empty())
            .previewDisplayName("Missing player")
    }
}
