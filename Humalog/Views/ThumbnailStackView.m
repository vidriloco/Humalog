//
//  ThumbnailStackView.m
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ThumbnailStackView.h"

#define TRANSITION_TIME 0.2

@implementation ThumbnailStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = iCarouselTypeLinear;
        self.vertical = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75];
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

- (void)reloadData
{
    [UIView animateWithDuration:TRANSITION_TIME / 2.0
                     animations:^{
                         self.contentView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [super reloadData];
                         [UIView animateWithDuration:TRANSITION_TIME / 2.0
                                          animations:^{
                                              self.contentView.alpha = 1.0;
                                          }];
                     }];
}

- (void)show
{
    self.hidden = NO;
    [UIView animateWithDuration:TRANSITION_TIME
                     animations:^{
                         self.alpha = 1.0; 
                         self.contentView.alpha = 1.0;
                     }];
}

- (void)hide
{
    [UIView animateWithDuration:TRANSITION_TIME
                     animations:^{
                         self.alpha = 0.0; 
                         self.contentView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

- (void)setBaseline:(CGPoint)baselineCenterPoint
{
    [UIView animateWithDuration:TRANSITION_TIME
                     animations:^{
                         self.frame = CGRectOffset(self.bounds, baselineCenterPoint.x - self.bounds.size.width / 2.0, baselineCenterPoint.y - self.bounds.size.height);
                     }];
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
