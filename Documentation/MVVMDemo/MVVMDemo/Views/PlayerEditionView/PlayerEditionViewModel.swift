import Combine
import GRDB
import Players

/// The view model for ``PlayerEditionView``.
final class PlayerEditionViewModel: ObservableObject {
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
        
        var playerExists: Bool {
            switch self {
            case .existing:
                return true
            case .gone, .missing:
                return false
            }
        }
    }
    
    /// The player to display.
    var player: Player? { playerPresence.player }
    
    /// A boolean indicating whether the "Player is gone" alert should
    /// be presented.
    @Published var gonePlayerAlertPresented = false
    
    @Published private var playerPresence: PlayerPresence = .missing
    private var observationCancellable: AnyCancellable?
    
    init(playerRepository: PlayerRepository, id: Int64) {
        observationCancellable = ValueObservation
            .tracking(Player.filter(key: id).fetchOne)
            .publisher(in: playerRepository.reader, scheduling: .immediate)
            // Use scan in order to detect the three cases of player presence
            .scan(PlayerPresence.missing) { (previous, player) in
                if let player {
                    return .existing(player)
                } else if let player = previous.player {
                    return .gone(player)
                } else {
                    return .missing
                }
            }
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] playerPresence in
                    guard let self = self else { return }
                    self.playerPresence = playerPresence
                    if !playerPresence.playerExists {
                        self.gonePlayerAlertPresented = true
                    }
                })
    }
}
