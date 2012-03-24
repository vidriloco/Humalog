//
//  MenubarView.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceControlDelegate.h"

@interface MenubarView : UIImageView {
    id<InterfaceControlDelegate> delegate;
}

@property (nonatomic, retain) id<InterfaceControlDelegate> delegate;

@end
