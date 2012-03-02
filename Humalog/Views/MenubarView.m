//
//  MenubarView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "MenubarView.h"
#import "GridLayout.h"
#define MENUBAR_IMAGE @"barra_menu.jpg"
#define MARGIN 15

@implementation MenubarView

- (id)init
{
    self = [super initWithImage:[UIImage imageNamed:MENUBAR_IMAGE]];
    if (self) {
        self.userInteractionEnabled = YES;
        
        // Section buttons
        NSArray *sections = [NSArray arrayWithObjects:
                             @"menu1.png",
                             @"menu2.png",
                             @"menu3.png",
                             @"menu4.png",
                             @"menu5.png",
                             nil];
        
        id sectionLayout = [GridLayout gridWithFrame:CGRectMake(MARGIN, 0, self.frame.size.width * 2 / 3, self.frame.size.height) numRows:1 numCols:[sections count]];
        int i = 0;
        for (NSValue* v in sectionLayout) {
            UIImage  *normalImage = [UIImage imageNamed:[sections objectAtIndex:i]];
            UIImage  *selectedImage = [UIImage imageNamed:[@"over_" stringByAppendingString:[sections objectAtIndex:i]]];
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
        
        // Nav buttons
        NSArray *buttons = [NSArray arrayWithObjects:
                            @"btn_apertura.png",
                            @"btn_cierre.png",
                            @"btn_estudios.png",
                            @"btn_ipp.png",
                            nil];

        
        id buttonLayout = [GridLayout gridWithFrame:CGRectMake(2 * MARGIN + self.frame.size.width * 2 / 3, 0, self.frame.size.width * 1 / 5, self.frame.size.height) numRows:1 numCols:[buttons count]];
        i = 0;
        for (NSValue* v in buttonLayout) {
            UIImage  *normalImage = [UIImage imageNamed:[buttons objectAtIndex:i]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
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
