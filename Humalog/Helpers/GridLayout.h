//
//  GridLayout.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridLayout : NSObject

+ (id)gridWithFrame:(CGRect)frame numRows:(int)numRows numCols:(int)numCols;

@end
