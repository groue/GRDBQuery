import SwiftUI
import GRDB
import GRDBQuery

/// The main application view
struct AppView: View {
    @DatabaseStateObject private var viewModel: AppViewModel
    
    init() {
        _viewModel = DatabaseStateObject(AppViewModel.init)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let player = viewModel.player {
                    PlayerView(player: player, edit: viewModel.editPlayer)
                        .padding(.vertical)
                    
                    Spacer()
                    populatedFooter()
                } else {
                    PlayerView(player: .placeholder)
                        .padding(.vertical)
                        .redacted(reason: .placeholder)
                    
                    Spacer()
                    emptyFooter()
                }
            }
            .padding(.horizontal)
            .sheet(item: $viewModel.editedPlayer) { player in
                PlayerEditionView(id: player.id)
            }
            .navigationTitle("@Query Demo")
        }
    }
    
    private func emptyFooter() -> some View {
        VStack {
            Text("The demo application observes the database and displays information about the player.")
                .informationStyle()
            
            CreateButton("Create a Player")
        }
        .informationBox()
    }
    
    private func populatedFooter() -> some View {
        VStack(spacing: 10) {
            Text("What if another application component deletes the player at the most unexpected moment?")
                .informationStyle()
            DeleteButton("Delete Player")
            
            Spacer().frame(height: 10)
            Text("What if the player is deleted soon after the Edit button is hit?")
                .informationStyle()
            DeleteButton("Delete After Editing", after: {
                viewModel.editPlayer()
            })
            
            Spacer().frame(height: 10)
            Text("What if the player is deleted right before the Edit button is hit?")
                .informationStyle()
            DeleteButton("Delete Before Editing", before: {
                viewModel.editPlayer()
            })
        }
        .informationBox()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
        AppView().environment(\.appDatabase, .populated())
    }
}
