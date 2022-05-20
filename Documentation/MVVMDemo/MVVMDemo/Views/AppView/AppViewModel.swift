import Combine
import GRDB

final class AppViewModel: ObservableObject {
    struct EditedPlayer: Identifiable {
        var id: Int64
    }

    @Published var player: Player?
    @Published var editedPlayer: EditedPlayer?
    private var cancellable: AnyCancellable?
    
    init(appDatabase: AppDatabase) {
        cancellable = ValueObservation
            .tracking(Player.fetchOne)
            .publisher(in: appDatabase.databaseReader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] player in
                    self?.player = player
                })
    }

    func editPlayer() {
        if let id = player?.id {
            editedPlayer = EditedPlayer(id: id)
        }
    }
}
