//
//  ThumbnailStackView.m
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ThumbnailStackView.h"

@implementation ThumbnailStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = iCarouselTypeLinear;
        self.vertical = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 8.0f;
//        self.layer.borderWidth = 3.0f;
//        self.layer.borderColor = [UIColor grayColor].CGColor;    
        
        // Shadow
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowRadius = 15.0f;
//        self.layer.shadowOpacity = 0.5f;
//        self.layer.shadowOffset = CGSizeMake(50.0f, 50.0f);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
