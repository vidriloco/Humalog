//
//  ToolbarView.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationControlDelegate.h"
#import "ContentNotificationDelegate.h"
#import "ToolControlDelegate.h"

@interface ToolbarView : UIImageView<ContentNotificationDelegate> {
    id<NavigationControlDelegate> navigationDelegate;
    id<ToolControlDelegate>       toolControlDelegate;
}

@property (nonatomic, retain) id<NavigationControlDelegate> navigationDelegate;
@property (nonatomic, retain) id<ToolControlDelegate>       toolControlDelegate;

- (void)hide;
- (void)show;
- (void)toggle;

@end
