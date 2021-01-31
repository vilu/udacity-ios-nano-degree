//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Viktor Lund on 17.01.21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var mapRegion: MapRegionRepositoryProtocol!
    var pinRepository: PinRepositoryProtocol!
    var photoRepositoroy: PhotoRepository!
    var flickerApi: FlickerApi!
    
    lazy var persistentContainer: PersistentContainer = {
        let container = PersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mapRegion = UserDefaultsRegionRepository()
        pinRepository = PinRepository(persistentContainer: persistentContainer)
        flickerApi = FlickerApi()
        photoRepositoroy = PhotoRepository(persistentContainer: persistentContainer)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
