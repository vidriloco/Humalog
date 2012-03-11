//
//  MasterController.h
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationControlDelegate.h"
#import "ContentDisplayDelegate.h"

@interface MasterController : UIViewController<NavigationControlDelegate, ContentDisplayDelegate> {
    int currentContentScreen;
}

@end
