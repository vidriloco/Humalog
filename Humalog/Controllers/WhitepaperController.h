//
//  WhitepaperController.h
//  Humalog
//
//  Created by Workstation on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "ContentControlProtocol.h"
#import "InterfaceControlDelegate.h"

@interface WhitepaperController : UIViewController<iCarouselDataSource, iCarouselDelegate, InterfaceControlDelegate> {
}

@end
