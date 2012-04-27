//
//  AppDelegate.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterController.h"
#import "Downloader.h"

@interface AppDelegate() {
    Downloader           *download;

}
@end

@implementation AppDelegate

@synthesize window = _window;


- (void) settingsChanged:(NSNotification *)paramNotification{
    NSLog(@"Settings changed");
    NSLog(@"Notification Object = %@", [paramNotification object]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(settingsChanged:) 
                                                 name:NSUserDefaultsDidChangeNotification 
                                               object:nil];
    
    BOOL flag=[[NSUserDefaults standardUserDefaults] boolForKey:@"update_interface_preference"];
    BOOL flag2=[[NSUserDefaults standardUserDefaults] boolForKey:@"update_slides_preference"];
    
    NSString *brandId=[[NSUserDefaults standardUserDefaults] stringForKey:@"brand_preference"];  
    
    
    
    if (flag || flag2) {
        
        download = [[Downloader alloc]init];
        [download parseJSON:brandId];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
        [defaults setBool:NO forKey:@"update_interface_preference"];
        [defaults setBool:NO forKey:@"update_slides_preference"];
        
    }

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    // Instance the master controller
    UIViewController *masterController = [[MasterController alloc] init];
    [self.window setRootViewController:masterController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
