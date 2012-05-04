//
//  WebContentView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "WebContentView.h"

@implementation WebContentView

// Content protocol methods
- (BOOL)playAction
{
    [self reload];
    return YES;
}

- (UIView *)contentSubview
{
    return self.scrollView;
}

@end