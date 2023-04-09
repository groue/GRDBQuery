import Combine
import GRDB
import Players

/// The view model for ``AppView``.
final class AppViewModel: ObservableObject {
    /// An `Identifiable` wrapper for a player id, able to be used as an
    /// item in SwiftUI `sheet(item:onDismiss:content:)`.
    struct EditedPlayerID: Identifiable {
        let id: Int64
        
        fileprivate init(id: Int64) {
            self.id = id
        }
    }
    
    /// The player to display.
    @Published private(set) var player: Player?
    
    /// The id of the player to edit.
    @Published var editedPlayer: EditedPlayerID?
    
    private var observationCancellable: AnyCancellable?
    
    init(playerRepository: PlayerRepository) {
        observationCancellable = ValueObservation
            .tracking(Player.fetchOne)
            .publisher(in: playerRepository.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] player in
                    self?.player = player
                })
    }
    
    /// Start editing the player.
    func editPlayer() {
        if let id = player?.id {
            editedPlayer = EditedPlayerID(id: id)
        }
    }
}
