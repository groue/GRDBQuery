import Combine
import GRDB

final class PlayerEditionViewModel: ObservableObject {
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
    
    var player: Player? { playerPresence.player }
    @Published var gonePlayerAlertPresented = false
    @Published private var playerPresence: PlayerPresence = .missing
    private var cancellable: AnyCancellable?
    
    init(appDatabase: AppDatabase, id: Int64) {
        cancellable = ValueObservation
            .tracking(Player.filter(id: id).fetchOne)
            .publisher(in: appDatabase.databaseReader, scheduling: .immediate)
            .scan(.missing) { (previous, player) in
                if let player = player {
                    return .existing(player)
                } else if let player = previous.player {
                    return .gone(player)
                } else {
                    return .missing
                }
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (playerPresence: PlayerPresence) in
                    guard let self = self else { return }
                    self.playerPresence = playerPresence
                    if !playerPresence.exists {
                        self.gonePlayerAlertPresented = true
                    }
                })
    }
}
