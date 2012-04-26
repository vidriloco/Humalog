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
@synthesize baseline;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = iCarouselTypeLinear;
        self.vertical = YES;
        self.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75];
        self.layer.cornerRadius = 8.0f;
        self.scrollEnabled = NO;
        self.centerItemWhenSelected = NO;
        self.baseline = CGPointZero;
        
        // Shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 15.0f;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 15.0f);
    }
    return self;
}

- (void)setNeedsLayout
{
    self.bounds = CGRectMake(0, 0, self.bounds.size.width, self.numberOfItems * self.itemWidth + 32.0);
    self.frame  = CGRectOffset(self.bounds, baseline.x - self.bounds.size.width / 2.0, baseline.y - self.bounds.size.height);
    self.contentOffset = CGSizeMake(0, (self.itemWidth - self.bounds.size.height + 16.0) / 2.0);
    [super setNeedsLayout];
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
                                              [self setNeedsLayout];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
