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

@interface MenubarView() {
    NSMutableArray *navButtons;
    NSMutableArray *sectionButtons;
    NSArray        *navActions;
}
@end

@implementation MenubarView
@synthesize delegate;

- (id)init
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];

    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"resources/"];
    
    NSString *menuBar=@"/backs/";
    menuBar = [menuBar stringByAppendingString:MENUBAR_IMAGE];
    self = [super initWithImage:[UIImage imageWithContentsOfFile:[newDir stringByAppendingString:menuBar]]];
    
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
        sectionButtons = [NSMutableArray array];

        id sectionLayout = [GridLayout gridWithFrame:CGRectMake(MARGIN, 0, self.frame.size.width * 2 / 3, self.frame.size.height) numRows:1 numCols:[sections count]];
        int i = 0;
        for (NSValue* v in sectionLayout) {
            //UIImage  *normalImage = [UIImage imageNamed:[sections objectAtIndex:i]];
            NSString *menu=@"/menu_btns/";
            menu=[menu stringByAppendingString:[sections objectAtIndex:i]];
            NSString *overMenu=@"/over_btns/";
            overMenu=[overMenu stringByAppendingString:[@"over_" stringByAppendingString:[sections objectAtIndex:i]]];
            UIImage  *normalImage = [UIImage imageWithContentsOfFile:[newDir stringByAppendingString:menu]];
            UIImage  *selectedImage = [UIImage imageWithContentsOfFile:[newDir stringByAppendingString:overMenu]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [sectionButtons addObject:button];
            [self addSubview:button];
            ++i;
        }
        
        // Nav buttons
        navButtons = [NSMutableArray array];
        
        NSArray *buttons = [NSArray arrayWithObjects:
                            @"btn_apertura.png",
                            @"btn_cierre.png",
                            @"btn_estudios.png",
                            @"btn_ipp.png",
                            nil];
        
        navActions = [NSArray arrayWithObjects:
                      [NSValue valueWithPointer:@selector(menubarViewDidPressApertura)],
                      [NSValue valueWithPointer:@selector(menubarViewDidPressCierre)],
                      [NSValue valueWithPointer:@selector(menubarViewDidPressEstudios)],
                      [NSValue valueWithPointer:@selector(menubarViewDidPressIPP)],
                      nil];

        id buttonLayout = [GridLayout gridWithFrame:CGRectMake(2 * MARGIN + self.frame.size.width * 2 / 3, 0, self.frame.size.width * 1 / 5, self.frame.size.height) numRows:1 numCols:[buttons count]];
        i = 0;
        for (NSValue* v in buttonLayout) {
            NSString *nav=@"/nav_btns/";
            nav = [nav stringByAppendingString:[buttons objectAtIndex:i]];
            UIImage  *normalImage = [UIImage imageWithContentsOfFile:[newDir stringByAppendingString:nav]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, normalImage.size.width, normalImage.size.height);
            button.center = [v CGPointValue];
            button.frame = CGRectIntegral(button.frame);
            [button setImage:normalImage forState:UIControlStateNormal];
            [self addSubview:button];
            [navButtons addObject:button];
            ++i;
        }
    }
    return self;
}

- (void)sectionPressed:(UIButton *)button
{
    if (button.selected) {
        button.selected = NO;
        [self.delegate menubarViewDidDeselectCategoryButton:button withIndex:[sectionButtons indexOfObject:button]];
        return;
    }
    
    for (UIButton *buttons in sectionButtons)
        buttons.selected = NO;
        
    button.selected = YES;
    [self.delegate menubarViewDidSelectCategoryButton:button withIndex:[sectionButtons indexOfObject:button]];
}

- (void)setDelegate:(id<InterfaceControlDelegate>)newDelegate
{
    // Update sections
    NSArray *buttons = sectionButtons;
    for (UIButton *button in buttons) {
        if (self.delegate) {
            [button removeTarget:self
                          action:NULL
                forControlEvents:UIControlEventTouchDown];
        }
        if ([newDelegate respondsToSelector:@selector(menubarViewDidSelectCategoryButton:withIndex:)]) {
            [button addTarget:self
                       action:@selector(sectionPressed:)
             forControlEvents:UIControlEventTouchDown];
            button.enabled = YES;
        } else {
            button.enabled = NO;
        }
    }
    // Update navigation
    buttons = navButtons;
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

    // Navigation
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
    if ([keyPath isEqualToString:@"navigationPosition"]) {
        
        enum NavigationPosition navigationPositionValue = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        
        UIButton *aperturaButton = [navButtons objectAtIndex:0];
        UIButton *cierreButton = [navButtons objectAtIndex:1];
        switch (navigationPositionValue) {
            case NavigationPositionFirstDocument:
                aperturaButton.enabled = NO;
                cierreButton.enabled = YES;
                break;
            case NavigationPositionLastDocument:
                aperturaButton.enabled = YES;
                cierreButton.enabled = NO;
                break;
            case NavigationPositionOtherDocument:
                aperturaButton.enabled = YES;
                cierreButton.enabled = YES;
                break;
            case NavigationPositionUndefined:
            default:
                aperturaButton.enabled = NO;
                cierreButton.enabled = NO;
                break;
        }
    }
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
