//
//  ContentNotificationDelegate.h
//  Humalog
//
//  Created by Workstation on 3/11/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContentNotificationDelegate <NSObject>
- (void)contentStarted;
- (void)contentFinished;
- (void)contentChanged;
@end
