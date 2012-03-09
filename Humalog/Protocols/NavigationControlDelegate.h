//
//  NavigationControlDelegate.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigationControlDelegate <NSObject>
- (void)toolbarViewDidPressBack;
- (void)toolbarViewDidPressForward;
- (void)toolbarViewDidPressPlay;
@end
