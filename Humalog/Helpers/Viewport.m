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

+ (CGRect)menuArea
{
    CGRect menuFrame = CGRectMake(0, 0, 1024, 99);
    return CGRectOffset(menuFrame, 0, [self screenArea].size.height - menuFrame.size.height);
}

+ (CGRect)contentArea
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self screenArea], &slice, &remainder, [self menuArea].size.height, CGRectMaxYEdge);
    return remainder;
}

@end
