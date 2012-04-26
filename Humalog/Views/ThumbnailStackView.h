//
//  ThumbnailStackView.h
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iCarousel.h"

@interface ThumbnailStackView : iCarousel {
    CGPoint baseline;
}
@property (nonatomic, assign) CGPoint baseline;
- (void)show;
- (void)hide;
@end
