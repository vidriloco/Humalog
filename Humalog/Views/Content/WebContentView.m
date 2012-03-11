//
//  CompositeView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "WebContentView.h"

@implementation WebContentView

static WebContentView *sharedInstance = nil;

+ (WebContentView *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[WebContentView alloc] init];
    });
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        // Permitir zoom
        self.scalesPageToFit = YES;
    }
    
    return self;
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// Content protocol methods

- (BOOL)playAction
{
    [[WebContentView sharedInstance] reload];
    return YES;
}

- (UIView *)getContentSubview
{
    return [[WebContentView sharedInstance] scrollView];
}


@end