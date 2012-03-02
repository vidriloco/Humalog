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

@implementation ToolbarView

- (id)init
{
    self = [super initWithImage:[UIImage imageNamed:TOOLBAR_IMAGE]];
    if (self) {
        self.userInteractionEnabled = YES;
        
        // Playback buttons
        NSArray *playback = [NSArray arrayWithObjects:
                             @"btn_rw.png",
                             @"btn_play.png",
                             @"btn_fw.png",
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
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
            [self addSubview:button];
            ++i;
        }
        
        // Tool buttons
        NSArray *tools = [NSArray arrayWithObjects:
                          @"pluma.png",
                          @"marcador.png",
                          @"goma.png",
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
            [button setImage:selectedImage forState:UIControlStateHighlighted];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [self addSubview:button];
            ++i;
        }
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
