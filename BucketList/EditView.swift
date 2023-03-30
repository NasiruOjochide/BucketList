//
//  EditView.swift
//  BucketList
//
//  Created by Danjuma Nasiru on 18/02/2023.
//

import SwiftUI

struct EditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel : EditView_ViewModel
    
    var onSave: (Location) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section("Nearby…") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    
                    onSave(newLocation)
                    
                    dismiss()
                }
            }
            .task{
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
    
    init(viewModel : EditView_ViewModel, onsave : @escaping (Location) -> Void){
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onsave
    }
    
    
}

//struct EditView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditView(location: Location.example, onsave: {_ in} )
//    }
//}
