//
//  ToolControlDelegate.h
//  Humalog
//
//  Created by Workstation on 3/11/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ToolControlDelegate <NSObject>
// Tools
- (void)toolbarViewDidSelectPen;
- (void)toolbarViewDidSelectMarker;
- (void)toolbarViewDidSelectEraser;
- (void)toolbarViewDidDeselectTool;
@end
