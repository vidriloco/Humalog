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

@interface AppDelegate() {
    Downloader       *download;
    BOOL             flag;
    BOOL             flag2;
    UIViewController *masterController;
    UIProgressView   *progress;

}
@end

@implementation AppDelegate

@synthesize window = _window;



- (void) settingsChanged:(NSNotification *)paramNotification{
    NSLog(@"Settings changed");
    NSLog(@"Notification Object = %@", [paramNotification object]);
}

- (void) setDefaults
{

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(settingsChanged:) 
                                                 name:NSUserDefaultsDidChangeNotification 
                                               object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"brand_preference"])  {
        
        NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString  *settingsPropertyListPath = [mainBundlePath
                                               stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        
        NSDictionary *settingsPropertyList = [NSDictionary 
                                              dictionaryWithContentsOfFile:settingsPropertyListPath];
        
        NSMutableArray      *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [preferenceArray count]; i++)  { 
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

-(void) downloadContent
{
    flag=[[NSUserDefaults standardUserDefaults] boolForKey:@"update_interface_preference"];
    flag2=[[NSUserDefaults standardUserDefaults] boolForKey:@"update_slides_preference"];
    
    download = [[Downloader alloc]init];
    download.delegate=self;
        
    if (flag || flag2) {
        NSString *brandId=[[NSUserDefaults standardUserDefaults] stringForKey:@"brand_preference"];  
        [download parseJSON:brandId];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        [defaults setBool:NO forKey:@"update_interface_preference"];
        [defaults setBool:NO forKey:@"update_slides_preference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } 
    else {
        [Brand updateElementsFromDefaults];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor clearColor];
    
    
    [self setDefaults];
    [self downloadContent];
   
    
    // Instance the master controller
    masterController = [[MasterController alloc] init];
    if(flag&&flag2)
    {
        progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

        
        UIImageView *vista = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"splash.png"]];
        [progress setFrame:CGRectMake(vista.frame.size.width/2.5, vista.frame.size.height/1.5, 200.0, 10.0)];
        [vista addSubview:progress];
        
        [masterController.view addSubview:vista];
    }
    [self.window setRootViewController:masterController];  
    [self.window makeKeyAndVisible];
    return YES;

}



-(void)downloaderDidFinish
{
    masterController = [[MasterController alloc] init];
    [self.window setRootViewController:masterController];  
}

-(void)downloaderIsDownloading
{
    progress.progress=download.advance;
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
