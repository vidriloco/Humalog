//
//  GridLayout.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "GridLayout.h"

@implementation GridLayout

+ (id)gridWithFrame:(CGRect)frame numRows:(int)numRows numCols:(int)numCols
{
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for (int i = 0; i < numRows; ++i) {
        for (int j = 0; j < numCols; ++j) {
            float x = CGRectGetMinX(frame) + (j + 0.5) * (CGRectGetMaxX(frame) - CGRectGetMinX(frame)) / numCols;
            float y = CGRectGetMinY(frame) + (i + 0.5) * (CGRectGetMaxY(frame) - CGRectGetMinY(frame)) / numRows;
            [output addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
    }
    return output;
}

@end
