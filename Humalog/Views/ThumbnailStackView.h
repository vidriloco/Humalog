//
//  ThumbnailStackView.h
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iCarousel.h"

@interface ThumbnailStackView : iCarousel

- (void)setBaseline:(CGPoint)baselineCenterPoint;
- (void)show;
- (void)hide;
@end
