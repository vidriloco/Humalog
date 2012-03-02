//
//  CompositeView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "CompositeView.h"
#import "ToolbarView.h"
#import "MenubarView.h"
#import "ContentView.h"

@implementation CompositeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor purpleColor];
        
        // Subviews
        UIImageView *toolbarView = [[ToolbarView alloc] init];
        UIImageView *menubarView = [[MenubarView alloc] init];
        UIWebView   *contentView = [[ContentView alloc] init];
        
        menubarView.frame = CGRectMake(0, frame.size.height - menubarView.image.size.height, menubarView.image.size.width, menubarView.image.size.height);
        contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - menubarView.bounds.size.height);
        
        [self addSubview:contentView];
        [self addSubview:menubarView];
        [self addSubview:toolbarView];
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
