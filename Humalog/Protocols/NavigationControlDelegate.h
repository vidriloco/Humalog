//
//  NavigationControlDelegate.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigationControlDelegate <NSObject>
// Nav
- (void)toolbarViewDidPressBack;
- (void)toolbarViewDidPressForward;
- (void)toolbarViewDidPressPlay;

- (void)menubarViewDidPressApertura;
- (void)menubarViewDidPressCierre;
- (void)menubarViewDidPressEstudios;
- (void)menubarViewDidPressIPP;

@end
