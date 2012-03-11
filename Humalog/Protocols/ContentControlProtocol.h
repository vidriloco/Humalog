//
//  ContentControlProtocol.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContentControlProtocol <NSObject>

- (BOOL)playAction;
- (UIView *)getContentSubview;

@end
