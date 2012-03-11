//
//  ToolbarView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "ToolbarView.h"
#import "GridLayout.h"
#define TOOLBAR_IMAGE @"barra_herramientas.png"
#define HIDE_DURATION 0.15

@interface ToolbarView() {
    NSMutableArray *navButtons;
    NSMutableArray *miniButtons;
    NSMutableArray *toolButtons;
    CGRect hiddenArea;
    CGRect displayArea;
}
@end

@implementation ToolbarView
@synthesize navigationDelegate;

- (id)init
{
    self = [super initWithImage:[UIImage imageNamed:TOOLBAR_IMAGE]];
    if (self) {
        self.userInteractionEnabled = YES;
        displayArea = self.frame;
        hiddenArea = CGRectOffset(displayArea, 0, -displayArea.size.height);
        
        // Playback buttons
        NSArray *playback = [NSArray arrayWithObjects:
                             @"btn_rw.png",
                             @"btn_play.png",
                             @"btn_fw.png",
                             nil];

        NSArray *playbackActions = [NSArray arrayWithObjects:
                                    [NSValue valueWithPointer:@selector(toolbarViewDidPressBack)],
                                    [NSValue valueWithPointer:@selector(toolbarViewDidPressPlay)],
                                    [NSValue valueWithPointer:@selector(toolbarViewDidPressForward)],
                                    nil];
        
        id playbackLayout = [GridLayout gridWithFrame:CGRectMake(0, 0, 196, self.frame.size.height) numRows:1 numCols:[playback count]];
        int i = 0;
        for (NSValue* v in playbackLayout) {
            UIImage  *normalImage = [UIImage imageNamed:[playback objectAtIndex:i]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
            [button addTarget:navigationDelegate
                       action:[[playbackActions objectAtIndex:i] pointerValue]
             forControlEvents:UIControlEventTouchDown];
            [button addTarget:self
                       action:@selector(navButtonPressed:)
             forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            [navButtons addObject:button];
            ++i;
        }
        
        // Mini layout buttons
        NSArray *miniOptions = [NSArray arrayWithObjects:
                             @"btn_minis_izq.png",
                             @"btn_minis_abajo.png",
                             nil];
        
        id miniLayout = [GridLayout gridWithFrame:CGRectMake(196 + 10, 0, 120, self.frame.size.height) numRows:1 numCols:[miniOptions count]];
        i = 0;
        for (NSValue* v in miniLayout) {
            UIImage  *normalImage = [UIImage imageNamed:[miniOptions objectAtIndex:i]];
            UIImage  *selectedImage = [UIImage imageNamed:[@"over_" stringByAppendingString:[miniOptions objectAtIndex:i]]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
            [button setImage:selectedImage forState:UIControlStateHighlighted];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [self addSubview:button];
            [miniButtons addObject:button];
            ++i;
        }
        
        // Tool buttons
        toolButtons = [NSMutableArray array];
        NSArray *tools = [NSArray arrayWithObjects:
                          @"pluma.png",
                          @"marcador.png",
                          @"goma.png",
                          nil];

        NSArray *toolActions = [NSArray arrayWithObjects:
                                [NSValue valueWithPointer:@selector(toolbarViewDidSelectPen)],
                                [NSValue valueWithPointer:@selector(toolbarViewDidSelectMarker)],
                                [NSValue valueWithPointer:@selector(toolbarViewDidSelectEraser)],
                                nil];
        
        id toolsLayout = [GridLayout gridWithFrame:CGRectMake(1024 - 300, 0, 250, self.frame.size.height) numRows:1 numCols:[tools count]];
        i = 0;
        for (NSValue* v in toolsLayout) {
            UIImage  *normalImage = [UIImage imageNamed:[tools objectAtIndex:i]];
            UIImage  *selectedImage = [UIImage imageNamed:[@"over_" stringByAppendingString:[tools objectAtIndex:i]]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
//            [button setImage:selectedImage forState:UIControlStateHighlighted];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [button addTarget:navigationDelegate
                       action:[[toolActions objectAtIndex:i] pointerValue]
             forControlEvents:UIControlEventTouchDown];
            [button addTarget:self
                       action:@selector(toolButtonPressed:)
             forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            [toolButtons addObject:button];
            ++i;
        }
    }
    return self;
}

- (void)navButtonPressed:(UIButton *)button
{
    // Deselect tool buttons
    for (UIButton *i in toolButtons) {
        if (i.selected) {
            [navigationDelegate toolbarViewDidDeselectTool];
            i.selected = NO;
        }
    }
}

- (void)toolButtonPressed:(UIButton *)button
{
    if (button.selected) {
        button.selected = NO;
        [navigationDelegate toolbarViewDidDeselectTool];
        return;
    }
    
    for (UIButton *i in toolButtons)
        i.selected = NO;
    
    button.selected = YES;
}

- (void)hide
{
    if (self.hidden)
        return;
    
    [UIView animateWithDuration:HIDE_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.frame = hiddenArea;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

- (void)show
{
    if (!self.hidden)
        return;
    
    self.hidden = NO;
    [UIView animateWithDuration:HIDE_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.frame = displayArea;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)toggle
{
   if (self.hidden)
       [self show];
    
    [self hide];
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
