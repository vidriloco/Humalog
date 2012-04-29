//
//  MenubarView.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MenubarView.h"
#import "GridLayout.h"
#define MENUBAR_IMAGE @"barra_menu.jpg"
#define MARGIN 15

@interface MenubarView() {
    NSMutableArray *navButtons;
    NSMutableArray *sectionButtons;
    NSArray        *navActions;
    int             noMenus;
    NSString        *newDir;
}
@end

@implementation MenubarView
@synthesize delegate;

- (NSArray *) setMenu:(int)menuNumber withMenus:(int) menus{
    NSArray *sections = [[NSArray alloc]init];
    
    if (menus==1){
        // Section buttons
       sections = [NSArray arrayWithObjects:
                             @"menu1.png",
                             @"menu2.png",
                             @"menu3.png",
                             @"menu4.png",
                             @"menu5.png",
                             nil];
        
    }else {
        
    
        switch (menuNumber) {
            case 1:
                sections = [NSArray arrayWithObjects:
                            @"menuA.png",
                            @"menuB.png",
                            nil];            
                return sections;
            case 2:
                sections = [NSArray arrayWithObjects:
                            @"menu1.png",
                            @"menu2.png",
                            @"menu3.png",
                            @"menu4.png",
                            nil];            
                return sections;
            case 3:
                sections = [NSArray arrayWithObjects:
                            @"menu5.png",
                            @"menu6.png",
                            @"menu7.png",
                            @"menu8.png",
                            nil];            
                return sections;    
            default:
                break;
        }
    }
    
    return sections;
}

- (void) setSectionButtons:(NSArray *)sections isMenuSelector:(BOOL)selector withSectionNumber:(int) section{
    
    sectionButtons = [NSMutableArray array];
    id sectionLayout = [GridLayout gridWithFrame:CGRectMake(MARGIN, 0, self.frame.size.width * 2 / 3, self.frame.size.height) numRows:1 numCols:[sections count]];
    int i = 0;
    for (NSValue* v in sectionLayout) {
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
        
        if(selector){
            button.tag=i+90;
        }else if (section==1){
            button.tag=section;
        }else {
            button.tag=section;
        }

        [sectionButtons addObject:button];
        [self addSubview:button];
        ++i;
    }
}

- (void) removeSelectorButtons:(NSArray *) buttons{
    for (UIButton * button in buttons){
        [button removeFromSuperview];
    }
}



- (id)init
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];

    newDir = [documentsDir stringByAppendingPathComponent:@"resources/"];
    
    NSString *menuBar=@"/backs/";
    menuBar = [menuBar stringByAppendingString:MENUBAR_IMAGE];
    
    noMenus = [[[NSUserDefaults standardUserDefaults] valueForKey:@"menus"]intValue];
    
    self = [super initWithImage:[UIImage imageWithContentsOfFile:[newDir stringByAppendingString:menuBar]]];
    
    if (self) {
        self.userInteractionEnabled = YES;

        BOOL flag=NO;
        int section=1;
        if (noMenus>1) {
            flag =YES;
            section=0;
        }
            [self setSectionButtons:[self setMenu:1 withMenus:noMenus] isMenuSelector:flag withSectionNumber:section];

               
        // Nav buttons
        navButtons = [NSMutableArray array];
        NSMutableArray * temp1 = [NSMutableArray array];
        NSMutableArray * temp2 = [NSMutableArray array];        

        for (int i=1; i<=6; i++) {
            id flag=[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%d",i]];
            if ([flag boolValue]) {
                
            switch (i) {
                case 1:
                    [temp1 addObject:@"btn_apertura.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressApertura)]];
                    break;
                case 2:
                    [temp1 addObject:@"btn_cierre.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressCierre)]];
                    break;                    
                case 3:
                    [temp1 addObject:@"btn_ipp.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressIPP)]];
                    break;
                case 4:
                    [temp1 addObject:@"btn_referencias.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressReferencias)]];
                    break;
                case 5:
                    [temp1 addObject:@"btn_especial.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressEspecial)]];
                    break;
                case 6:
                    [temp1 addObject:@"btn_estudios.png"];
                    [temp2 addObject:[NSValue valueWithPointer:@selector(menubarViewDidPressEstudios)]];
                    break;
            }
            }
            
        }


        
        NSArray *buttons = [NSArray arrayWithArray:temp1];
        
        navActions = [NSArray arrayWithArray:temp2];

        id buttonLayout = [GridLayout gridWithFrame:CGRectMake(2 * MARGIN + self.frame.size.width * 2 / 3, 0, self.frame.size.width * 1 / 5, self.frame.size.height) numRows:1 numCols:[buttons count]];
        int i = 0;
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


- (void)selectMenu:(UIButton *)button{
    if (button.tag==90){
        NSLog(@"%d",button.tag);
        [self removeSelectorButtons:sectionButtons];
        [self setSectionButtons:[self setMenu:2 withMenus:noMenus] isMenuSelector:NO withSectionNumber:1];
        [self.delegate menubarViewDidSelectCategoryButton:button withIndex:0];
        
    }else if(button.tag==91){
        [self removeSelectorButtons:sectionButtons];
        [self setSectionButtons:[self setMenu:3 withMenus:noMenus] isMenuSelector:NO withSectionNumber:2];
        [self.delegate menubarViewDidSelectCategoryButton:button withIndex:4];
        
    }
    self.delegate = delegate;    
}

- (void)deselectButtons
{
    for (UIButton *buttons in sectionButtons)
        buttons.selected = NO;
}

- (void)sectionPressed:(UIButton *)button
{
    if (button.selected) {
        button.selected = NO;
        [self.delegate menubarViewDidDeselectCategoryButton:button withIndex:[sectionButtons indexOfObject:button]];
        return;
    }
    
    [self deselectButtons];
        
    button.selected = YES;
    
    if (button.tag==1) {
        [self.delegate menubarViewDidSelectCategoryButton:button withIndex:[sectionButtons indexOfObject:button]];
    }else if (button.tag==2){
        [self.delegate menubarViewDidSelectCategoryButton:button withIndex:[sectionButtons indexOfObject:button]+4];
    }

}

- (void)setDelegate:(id<InterfaceControlDelegate>)newDelegate
{
    // Update sections
    NSArray *buttons = sectionButtons;
    for (UIButton *button in buttons) {
        if (button.tag>=90) {
            
            [button addTarget:self
                       action:@selector(selectMenu:)
             forControlEvents:UIControlEventTouchDown];
            button.enabled = YES;
            
        }else {
        
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
    
    [(NSObject *)delegate removeObserver:self
                              forKeyPath:@"currentCategoryIndex"];
    
    [(NSObject *)newDelegate addObserver:self
                              forKeyPath:@"currentCategoryIndex"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
        
    delegate = newDelegate;

}


- (CGPoint)centerForSectionButtonWithIndex:(NSUInteger)index
{
    if (index >= [sectionButtons count])
        return CGPointZero;
    
    return ((UIButton *)[sectionButtons objectAtIndex:index]).center;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"navigationPosition"]) {
                
        [self deselectButtons];
        enum NavigationPosition navigationPositionValue = [[change objectForKey:NSKeyValueChangeNewKey] intValue];

        UIButton *aperturaButton = [navButtons objectAtIndex:0];
        UIButton *cierreButton = [navButtons objectAtIndex:1];
        switch (navigationPositionValue) {
            case NavigationPositionFirstDocument:
                if (noMenus>1) {
                [self removeSelectorButtons:sectionButtons];
                [self setSectionButtons:[self setMenu:1 withMenus:noMenus] 
                         isMenuSelector:YES 
                      withSectionNumber:0];
                self.delegate=delegate;
                }
                aperturaButton.enabled = YES;
                cierreButton.enabled = YES;
                break;
//            case NavigationPositionLastDocument:
//                aperturaButton.enabled = YES;
//                cierreButton.enabled = NO;
//                break;
//            case NavigationPositionOtherDocument:
//                aperturaButton.enabled = YES;
//                cierreButton.enabled = YES;
//                break;
//            case NavigationPositionUndefined:
//            default:
//                aperturaButton.enabled = NO;
//                cierreButton.enabled = NO;
//                break;
        
        }
    } else if ([keyPath isEqualToString:@"currentCategoryIndex"]) {
        NSUInteger newCategoryIndex = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
       
        for (UIButton *button in sectionButtons) {
            button.layer.shadowOpacity = 0.0;
            button.layer.shadowRadius = 0.0;
            button.layer.shadowColor = [UIColor clearColor].CGColor;
        }

        
        if (newCategoryIndex>=[sectionButtons count]) {
            return;
        }
        
        
        UIButton *button = (UIButton *) [sectionButtons objectAtIndex:newCategoryIndex];
        button.layer.shadowOpacity = 0.8;
        button.layer.shadowRadius = 6.0;
        button.layer.shadowColor = [UIColor whiteColor].CGColor;

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
