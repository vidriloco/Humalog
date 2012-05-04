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
#import "Brand.h"
#import "SplashscreenViewController.h"
#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;

@interface AppDelegate() {
    SplashscreenViewController *splashController;
    Downloader                 *download;
    BOOL                        flag;
    BOOL                        flag2;
}
@end

@implementation AppDelegate

@synthesize window = _window;

- (void)loadMasterController
{
    [self.window setRootViewController:[[MasterController alloc] init]];  
}

- (void)settingsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Settings changed");
    NSLog(@"Notification Object = %@", [paramNotification object]);
}

- (void)setDefaults
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(settingsChanged:) 
                                                 name:NSUserDefaultsDidChangeNotification 
                                               object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"brand_preference"]) {
        
        NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString  *settingsPropertyListPath = [mainBundlePath
                                               stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        
        NSDictionary *settingsPropertyList = [NSDictionary 
                                              dictionaryWithContentsOfFile:settingsPropertyListPath];
        
        NSMutableArray      *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [preferenceArray count]; ++i)  { 
            NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
            
            if (key)  {
                id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                [registerableDictionary setObject:value forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary]; 
        [[NSUserDefaults standardUserDefaults] synchronize]; 
    }
}

- (void)downloadContent
{
    flag  = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_interface_preference"];
    flag2 = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_slides_preference"];
    
    if (flag || flag2) {
        NSString *brandId = [[NSUserDefaults standardUserDefaults] stringForKey:@"brand_preference"];  
        download = [[Downloader alloc] init];
        download.delegate = self;
        [download parseJSON:brandId];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        [defaults setBool:NO forKey:@"update_interface_preference"];
        [defaults setBool:NO forKey:@"update_slides_preference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Updates the singleton
    [Brand updateElementsFromDefaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-31202291-1"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    NSError *error;
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"iPad3"
                                                        value:@"ip1"
                                                    withError:&error]) {
        // Handle error here
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    splashController = [[SplashscreenViewController alloc] init];
    [self.window setRootViewController:splashController];
    [self.window makeKeyAndVisible];
    
    [self setDefaults];
    [self downloadContent];
    
    // Instance the master controller
    if (!(flag && flag2))
        [self loadMasterController];

    return YES;
}

- (void)downloaderDidFinish
{
    [self loadMasterController];
}

- (void)downloaderIsDownloading
{
    splashController.progress.progress = download.advance;
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
    [[GANTracker sharedTracker] stopTracker];
}

@end
