//
//  ContentView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "ContentView.h"

@implementation ContentView

- (id)init
{
    if ((self = [super init])) {
        // Init
        self.backgroundColor = [UIColor grayColor];
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.astrazeneca.com"]]];
    }
    return self;
}

@end
