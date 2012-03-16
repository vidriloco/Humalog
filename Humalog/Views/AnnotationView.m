//
//  AnnotationView.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "AnnotationView.h"

#define MARKER_STROKE_WIDTH 18.0
#define MARKER_COLOR [UIColor colorWithRed:0.8 green:1.0 blue:0.1 alpha:0.3]

#define PEN_STROKE_WIDTH 1.5
#define PEN_COLOR [UIColor colorWithRed:0.1 green:0.2 blue:0.8 alpha:0.8]

#define EPSILON 0.0001

@interface AnnotationView() 
{
    float zoomScale;
    CGPoint origin;
    enum AnnotationPathType creatingPathOfType;
    NSMutableArray *currentPath;
}
@end

@implementation AnnotationView
@synthesize penPaths, markerPaths;

- (id)initWithFrame:(CGRect)frame andMasterView:(UIView *)masterView
{
    if ((self = [super initWithFrame:frame])) {
        // Init
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        creatingPathOfType = PathTypeNone;
        origin = CGPointZero;
        zoomScale = 1.0;
        
        // Observing the master view for content changes
        [masterView addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
                
        [masterView addObserver:self
                     forKeyPath:@"contentSize"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
    }
    return self;
}

- (CGPoint)transformPoint:(CGPoint)point
{
    return CGPointMake(point.x * zoomScale - origin.x,
                       point.y * zoomScale - origin.y);
}

- (CGPoint)reverseTransformPoint:(CGPoint)point
{
    return CGPointMake((point.x + origin.x) / zoomScale,
                       (point.y + origin.y) / zoomScale);
}

- (UIBezierPath *)buildPathFromCGPointArray:(NSArray *)pointArray
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    // Enough points?
    if ([pointArray count] < 2)
        return bezierPath;
    
    // Move to the first point
    CGPoint point = [self transformPoint:[[pointArray objectAtIndex:0] CGPointValue]];
    [bezierPath moveToPoint:point];
    
    // Connect the remaining ones
    for (int i = 1; i < [pointArray count]; ++i) {
        point = [self transformPoint:[[pointArray objectAtIndex:i] CGPointValue]];
        [bezierPath addLineToPoint:point];
    }
    return bezierPath;
}

- (void)drawPaths:(NSArray *)paths
  withStrokeColor:(UIColor *)strokeColor
   andStrokeWidth:(float)strokeWidth
       withinRect:(CGRect)rect
{
    for (NSArray *path in paths) {
        UIBezierPath *bezierPath = [self buildPathFromCGPointArray:path];
        
        // Stroke setup
        bezierPath.lineWidth = strokeWidth * zoomScale;
        [strokeColor setStroke];
        
        // Paint with no off-screen drawing
        if (CGRectIntersectsRect(rect, CGRectInset(bezierPath.bounds, -bezierPath.lineWidth / 2.0, -bezierPath.lineWidth / 2.0)))
            [bezierPath stroke];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Draw marker paths
    [self drawPaths:markerPaths
    withStrokeColor:MARKER_COLOR
     andStrokeWidth:MARKER_STROKE_WIDTH
         withinRect:rect];

    // Draw pen paths
    [self drawPaths:penPaths
    withStrokeColor:PEN_COLOR
     andStrokeWidth:PEN_STROKE_WIDTH 
         withinRect:rect];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context 
{    
    // Origin
    if (keyPath == @"contentOffset") {
        origin = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
    }
    // Zoom
    else if (keyPath == @"contentSize") {
        CGSize newSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        zoomScale = newSize.width / self.frame.size.width;
    }
    [self setNeedsDisplay];
}

// Path creation
- (void)startDrawing:(enum AnnotationPathType)pathType
{
    // Init
    if (!self.penPaths)
        self.penPaths = [NSMutableArray array];
   
    if (!self.markerPaths)
        self.markerPaths = [NSMutableArray array];

    creatingPathOfType = pathType;
    self.userInteractionEnabled = YES;
}

- (void)finishDrawing
{
    creatingPathOfType = PathTypeNone;
    self.userInteractionEnabled = NO;
}

- (BOOL)lineSegmentsIntersectWithFirstPoint:(CGPoint)p1
                                     second:(CGPoint)p2
                                      third:(CGPoint)p3
                                     fourth:(CGPoint)p4
{
    float d = ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y));
    
    // Parallel?
    if (abs(d) < EPSILON)
        return NO;
    
    float u = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / d;
    float v = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / d;
    
    if ((u >= 0.0 && u <= 1.0) && (v >= 0.0 && v <= 1.0))
        return YES;
    
    return NO;
}

- (void)checkAndErasePath:(NSMutableArray *)paths
{
    NSMutableArray *markedForDeletion = [NSMutableArray array];

    // Need only check the last eraser path's line segment for intersection
    CGPoint eraserA = [[currentPath objectAtIndex:currentPath.count - 2] CGPointValue];
    CGPoint eraserB = [[currentPath lastObject] CGPointValue];
    CGRect eraserBB = CGRectMake(eraserA.x, eraserA.y, eraserB.x - eraserA.x, eraserB.y - eraserA.y);
    
    for (NSArray *path in paths) {
        for (int i = 0; i < path.count - 1; ++i) {
            CGPoint line1A = [[path objectAtIndex:i] CGPointValue];
            CGPoint line1B = [[path objectAtIndex:i + 1] CGPointValue];
            CGRect  lineBB = CGRectMake(line1A.x, line1A.y, line1B.x - line1A.x, line1B.y - line1A.y);
            
            // Broad-phase intersection check
            if (!CGRectIntersectsRect(lineBB, eraserBB))
                continue;
            
            // Refined line-segment intersection
            if ([self lineSegmentsIntersectWithFirstPoint:line1A
                                                   second:line1B
                                                    third:eraserA
                                                   fourth:eraserB])
                [markedForDeletion addObject:path];
        }
    } 
    [paths removeObjectsInArray:markedForDeletion];
}

- (void)checkAndErasePaths
{
    // Check and erase marker paths
    [self checkAndErasePath:self.markerPaths];
    // Check and erase pen paths
    [self checkAndErasePath:self.penPaths];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (creatingPathOfType == PathTypeNone)
        return;
    
    currentPath = [NSMutableArray array];
    CGPoint location = [self reverseTransformPoint:[[touches anyObject] locationInView:self]];
    [currentPath addObject:[NSValue valueWithCGPoint:location]];
    
    // Collect the newly created path into the suiting array
    switch (creatingPathOfType) {
        case PathTypePen:
            [self.penPaths addObject:currentPath];
            break;
        case PathTypeMarker:
            [self.markerPaths addObject:currentPath];
            break;
        case PathTypeEraser:
            break;
        case PathTypeNone:
        default:
            currentPath = nil;
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!currentPath)
        return;
    
    CGPoint location = [self reverseTransformPoint:[[touches anyObject] locationInView:self]];
    
    // Markers should only produce straight lines
    if (creatingPathOfType == PathTypeMarker)
        location.y = [currentPath.lastObject CGPointValue].y;
    
    [currentPath addObject:[NSValue valueWithCGPoint:location]];
    
    // Is erasing?
    if (creatingPathOfType == PathTypeEraser)
        [self checkAndErasePaths];
    
    // Let's redraw
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Add the last point
    [self touchesMoved:touches withEvent:event];
    
    currentPath = nil;
    
    // Let's redraw
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
