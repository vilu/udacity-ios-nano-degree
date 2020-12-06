import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var memes = [Meme]()
//    var memes = [
//        Meme(topText: "top text 1", originalImage: UIImage(named: "LaunchImage"), memedImage: UIImage(named: "LaunchImage"), bottomText: "bottom text 1"),
//        Meme(topText: "top text 2", originalImage: UIImage(named: "LaunchImage"), memedImage: UIImage(named: "LaunchImage"), bottomText: "bottom text 2"),
//        Meme(topText: "top text 3", originalImage: UIImage(named: "LaunchImage"), memedImage: UIImage(named: "LaunchImage"), bottomText: "bottom text 3"),
//        Meme(topText: "top text 4", originalImage: UIImage(named: "LaunchImage"), memedImage: UIImage(named: "LaunchImage"), bottomText: "bottom text 4"),
//        Meme(topText: "top text 5", originalImage: UIImage(named: "LaunchImage"), memedImage: UIImage(named: "LaunchImage"), bottomText: "bottom text 5")
//    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

