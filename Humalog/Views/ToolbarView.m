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
    
    NSArray *navActions;
    NSArray *toolActions;
    
    CGRect hiddenArea;
    CGRect displayArea;
}
@end

@implementation ToolbarView
@synthesize delegate;

// TODO: Beautify

- (id)init
{
    self = [super initWithImage:[UIImage imageNamed:TOOLBAR_IMAGE]];
    if (self) {
        self.userInteractionEnabled = YES;
        displayArea = self.frame;
        hiddenArea = CGRectOffset(displayArea, 0, -displayArea.size.height);
        
        // Playback buttons
        navButtons = [NSMutableArray array];
        
        NSArray *playback = [NSArray arrayWithObjects:
                             @"btn_rw.png",
                             @"btn_play.png",
                             @"btn_fw.png",
                             nil];
        
        navActions = [NSArray arrayWithObjects:
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
            [self addSubview:button];
            [navButtons addObject:button];
            ++i;
        }
        
        // Mini layout buttons
        miniButtons = [NSMutableArray array];
        
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
            button.enabled = NO;
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
        
        toolActions = [NSArray arrayWithObjects:
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

- (void)setDelegate:(id<InterfaceControlDelegate>)newDelegate
{
    // Update navigation
    NSArray *buttons = navButtons;
    NSArray *actions = navActions;
    for (UIButton *button in buttons) {
        if (self.delegate) {
            [button removeTarget:self.delegate
                          action:NULL
                forControlEvents:UIControlEventTouchDown];
        }
        SEL action = [[actions objectAtIndex:[buttons indexOfObject:button]] pointerValue];
        if ([newDelegate respondsToSelector:action]) {
            [button addTarget:newDelegate
                       action:action
             forControlEvents:UIControlEventTouchDown];
            button.enabled = YES;
        } else {
            button.enabled = NO;
        }
    }
    
    // Update tools
    buttons = toolButtons;
    actions = toolActions;
    for (UIButton *button in buttons) {
        if (self.delegate) {
            [button removeTarget:self.delegate
                          action:NULL
                forControlEvents:UIControlEventTouchDown];
        }
        SEL action = [[actions objectAtIndex:[buttons indexOfObject:button]] pointerValue];
        if ([newDelegate respondsToSelector:action]) {
            [button addTarget:newDelegate
                       action:action
             forControlEvents:UIControlEventTouchDown];
            button.enabled = YES;
        } else {
            button.enabled = NO;
        }
    }
    
    [(NSObject *)delegate removeObserver:self
                              forKeyPath:@"navigationPosition"];
    
    [(NSObject *)newDelegate addObserver:self
                              forKeyPath:@"navigationPosition"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    
    delegate = newDelegate;
}
     
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (![keyPath isEqualToString:@"navigationPosition"])
        return;

    enum NavigationPosition navigationPositionValue = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
    
    UIButton *prevButton = [navButtons objectAtIndex:0];
    UIButton *nextButton = [navButtons lastObject];
    switch (navigationPositionValue) {
        case NavigationPositionFirstDocument:
            prevButton.enabled = NO;
            nextButton.enabled = YES;
            break;
        case NavigationPositionLastDocument:
            prevButton.enabled = YES;
            nextButton.enabled = NO;
            break;
        case NavigationPositionOtherDocument:
            prevButton.enabled = YES;
            nextButton.enabled = YES;
            break;
        case NavigationPositionUndefined:
        default:
            prevButton.enabled = NO;
            nextButton.enabled = NO;
            break;
    }
    
    // Deselect tool buttons
    for (UIButton *i in toolButtons) {
        if (i.selected) {
            [self.delegate toolbarViewDidDeselectTool];
            i.selected = NO;
        }
    }
    [self hide];
}

- (void)toolButtonPressed:(UIButton *)button
{
    if (button.selected) {
        button.selected = NO;
        [self.delegate toolbarViewDidDeselectTool];
        [self hide];
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
