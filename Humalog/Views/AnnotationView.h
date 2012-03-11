//
//  AnnotationView.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <UIKit/UIKit.h>

enum AnnotationPathType {
    PathTypeNone = 0,
    PathTypePen,
    PathTypeEraser,
    PathTypeMarker
};

@interface AnnotationView : UIView {
    NSMutableArray *penPaths;
    NSMutableArray *markerPaths;
}
@property (nonatomic, retain) NSMutableArray *penPaths;
@property (nonatomic, retain) NSMutableArray *markerPaths;

- (id)initWithFrame:(CGRect)frame andMasterView:(UIView *)masterView;
- (void)startDrawing:(enum AnnotationPathType)pathType;
- (void)finishDrawing;

@end
