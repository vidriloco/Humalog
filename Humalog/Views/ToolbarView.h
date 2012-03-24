//
//  ToolbarView.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceControlDelegate.h"

@interface ToolbarView : UIImageView {
    id<InterfaceControlDelegate> delegate;
}
@property (nonatomic, retain) id<InterfaceControlDelegate> delegate;

- (void)hide;
- (void)show;
- (void)toggle;

@end
