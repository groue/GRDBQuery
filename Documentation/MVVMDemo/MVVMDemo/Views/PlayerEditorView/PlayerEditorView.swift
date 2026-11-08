import GRDBQuery
import SwiftUI

/// The sheet for editing a player.
///
/// In this demo app, this view doesn't want to remain on screen
/// whenever the edited player no longer exists in the database.
struct PlayerEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentStateObject private var viewModel: PlayerEditorViewModel
    
    init(id: Int64) {
        _viewModel = EnvironmentStateObject {
            PlayerEditorViewModel(playerRepository: $0.playerRepository, id: id)
        }
    }
    
    var body: some View {
        NavigationView {
            if let player = viewModel.player {
                VStack {
                    PlayerFormView(player: player)
                    Spacer()
                    VStack(spacing: 10) {
                        Text("What if another application component deletes the player at the most unexpected moment?")
                            .informationStyle()
                        DeletePlayersButton("Delete Player")
                    }
                    .informationBox()
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
        .alert(
            "Ooops, player is gone.",
            isPresented: $viewModel.gonePlayerAlertPresented) {
                Button("Dismiss") { dismiss() }
            }
    }
}

// MARK: - Previews

#Preview("Existing player") {
    PlayerEditorView(id: 1)
        .playerRepository(.populated(playerId: 1))
}

#Preview("Missing player") {
    PlayerEditorView(id: -1)
        .playerRepository(.empty())
}
