//
//  NavigationControlDelegate.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

enum NavigationPosition {
    NavigationPositionFirstDocument,
    NavigationPositionLastDocument,
    NavigationPositionOtherDocument,
    NavigationPositionUndefined
};

enum ThumbnailNavigationType {
    ThumbnailNavigationTypeGeneral,
    ThumbnailNavigationTypePerCategory
};

@protocol InterfaceControlDelegate <NSObject>
// Nav
@optional
- (void)toolbarViewDidPressBack;
- (void)toolbarViewDidPressForward;
- (void)toolbarViewDidPressPlay;

- (void)menubarViewDidPressApertura;
- (void)menubarViewDidPressCierre;
- (void)menubarViewDidPressEstudios;
- (void)menubarViewDidPressEspecial;
- (void)menubarViewDidPressIPP;
- (void)menubarViewDidPressReferencias;

- (void)menubarViewDidSelectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index;
- (void)menubarViewDidDeselectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index;


// Toolbar
- (void)toolbarViewDidSelectPen;
- (void)toolbarViewDidSelectMarker;
- (void)toolbarViewDidSelectEraser;
- (void)toolbarViewDidDeselectTool;

- (void)toolbarViewDidPressThumbnailsLeft;
- (void)toolbarViewDidPressThumbnailsBottom;

@end
