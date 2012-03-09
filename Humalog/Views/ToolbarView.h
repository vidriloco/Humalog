//
//  ToolbarView.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationControlDelegate.h"

@interface ToolbarView : UIImageView {
    id<NavigationControlDelegate> navigationDelegate;
}
@property (nonatomic, retain) id<NavigationControlDelegate> navigationDelegate;

- (void)hide;
- (void)show;
- (void)toggle;

@end
