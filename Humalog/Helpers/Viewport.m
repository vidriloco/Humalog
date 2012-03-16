//
//  Viewport.m
//  Humalog
//
//  Created by Workstation on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Viewport.h"

@implementation Viewport

+ (CGRect)screenArea
{
    return CGRectMake(0, 0, 1024, 768);
}

+ (CGRect)contentArea
{
    return [self screenArea];
}

@end
