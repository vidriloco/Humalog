//
//  WebContentView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "WebContentView.h"

@implementation WebContentView

//static WebContentView *sharedInstance = nil;
//
//+ (WebContentView *)sharedInstance {
//    if (nil != sharedInstance) {
//        return sharedInstance;
//    }
//    
//    static dispatch_once_t pred;        // Lock
//    dispatch_once(&pred, ^{             // This code is called at most once per app
//        sharedInstance = [[WebContentView alloc] init];
//    });
//    
//    return sharedInstance;
//}
//
//- (id)init
//{
//    if ((self = [super init])) {
//        // Init
//    }
//    return self;
//}
//
//- (id)copyWithZone:(NSZone *)zone
//{
//    return self;
//}

// Content protocol methods
- (BOOL)playAction
{
    [self reload];
    return YES;
}

- (UIView *)getContentSubview
{
    return self.scrollView;
}

@end