//
//  AppDelegate.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadControlDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,DownloadControlDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
