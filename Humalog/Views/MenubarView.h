//
//  MenubarView.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationControlDelegate.h"
#import "ContentNotificationDelegate.h"

@interface MenubarView : UIImageView<ContentNotificationDelegate> {
    id<NavigationControlDelegate> navigationDelegate;
}

@property (nonatomic, retain) id<NavigationControlDelegate> navigationDelegate;

@end
