//
//  SlideController.h
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "ContentDisplayDelegate.h"
#import "InterfaceControlDelegate.h"

@interface SlideController : UIViewController<iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate, ContentDisplayDelegate, InterfaceControlDelegate>

@end
