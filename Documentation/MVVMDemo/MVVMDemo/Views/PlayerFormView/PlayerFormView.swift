import GRDB
import SwiftUI

/// The view that edits a player
struct PlayerFormView: View {
    @DatabaseStateObject private var viewModel: PlayerFormViewModel
    
    init(player: Player) {
        _viewModel = DatabaseStateObject { appDatabase in
            PlayerFormViewModel(appDatabase: appDatabase, editedPlayer: player)
        }
    }
    
    var body: some View {
        Stepper(
            "Score: \(viewModel.player.score)",
            onIncrement: { viewModel.incrementScore() },
            onDecrement: { viewModel.decrementScore() })
    }
}

struct PlayerFormView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerFormView(player: .makeRandom())
            .padding()
    }
}
