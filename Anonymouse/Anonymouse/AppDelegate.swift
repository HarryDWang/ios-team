//
//  AppDelegate.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier!
    var connectivityController: AnonymouseConnectivityController!
    var dataController: AnonymouseDataController!
    //var peripheralDelegate: AnonymousePeripheralManagerDelegate!
    //var centralDelegate: AnonymouseCentralManagerDelegate!
    //var region : CLBeaconRegion? = nil;
    //let locationManager : CLLocationManager = CLLocationManager.init();
    //var newManager: CBCentralManager = CBCentralManager.init()
    //var timer: Timer = Timer.init()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController = AnonymouseDataController()
        //peripheralDelegate = AnonymousePeripheralManagerDelegate()
        connectivityController = AnonymouseConnectivityController()
        //centralDelegate = AnonymouseCentralManagerDelegate()
        //newManager = CBCentralManager.init(delegate: self.centralDelegate, queue: nil, options: nil)
        
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        let mainTabBarController: AnonymouseTabBarController = AnonymouseTabBarController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.rootViewController = mainTabBarController
        self.window!.makeKeyAndVisible()
        
        let userPreferences: UserDefaults = UserDefaults.standard
        let defaultPreferencesFile: URL = Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist")!
        let defaultPreferencesDictionary: NSDictionary = NSDictionary(contentsOf: defaultPreferencesFile)!
        
        userPreferences.register(defaults: defaultPreferencesDictionary as! [String : Any])
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion: CLBeaconRegion) {
        print("Found a beacon")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        /*print("Did enter background");
        var newUUID : CBUUID
        newUUID = CBUUID.init(string: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
        print(newManager.state.rawValue)
        timer.tolerance = 0.5
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            self.newManager.stopScan()
            if(self.newManager.state == .poweredOn){
                self.newManager.scanForPeripherals(withServices: [newUUID], options: nil)
            }
        } */
        self.connectivityController.killConnectionParameters()
    }
    
        
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.connectivityController.startBrowsingForPeers()
        self.connectivityController.startAdvertisingPeer()

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.dataController.saveContext()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("\(application) called performFetchWithCompletionHandler")
        
        
        
        //self.connectivityController.startAdvertisingPeer()
        //self.connectivityController.startBrowsingForPeers()
        
        //DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: DispatchTime.now() + 20.0) {
           // NSLog("\(application) called the completionHandler")
            //self.connectivityController.killConnectionParameters()
           // completionHandler(UIBackgroundFetchResult.noData)
        //}
        
        
    }
}

