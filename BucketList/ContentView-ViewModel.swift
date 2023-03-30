//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Danjuma Nasiru on 21/02/2023.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView{
    @MainActor class ViewModel : ObservableObject{
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        @Published private(set) var locations : [Location]
        
        @Published var selectedPlace: Location?
        
        @Published var isUnlocked = false
        
        @Published var authFailed = false
        
        @Published var authFailedMsg = ""
        
        @Published var authFailedDesc = ""
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("savedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save(){
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation(){
            let newLocation = Location(id: UUID(), name: "new location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location : Location){
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace){
                locations[index] = location
                save()
            }
        }
        
        func authenticate(){
            let context = LAContext()
            var error : NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is to protect your data", reply: {success, authenticationError in
                    Task{@MainActor in
                        if success{
                            //we use task here because even though we've put our class inside main actor so that every chnge to the class is handled by mainactor and run on main thread, the evaluate policy method in which we're setting the unlockd property is handled by apple and is done in the background, so we have to use mainactor in here as well
                            //                        Task{
                            //                            await MainActor.run{
                            //                                self.isUnlocked = true
                            //                            }
                            //                        } or this way below
                            //                        Task{@MainActor in
                            //                            self.isUnlocked = true
                            //                        }
                            
                            self.isUnlocked = true
                            
                        }else{
                            //
                        }
                    }
                })
            }else{
                self.authFailed = true
                self.authFailedMsg = "Failed!"
                self.authFailedDesc = "Device does not support Biometric scan"
            }
            
        }
    }
}
