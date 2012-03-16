//
//  MasterController.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "ContentControlProtocol.h"
#import "MasterController.h"
#import "SlideProvider.h"
#import "ToolbarView.h"
#import "MenubarView.h"
#import "AnnotationView.h"
#import "WhitepaperController.h"
#import "Viewport.h"

#define FADE_DURATION 0.25

// Private
@interface MasterController() {
    SlideProvider                  *contentProvider;
    UIView<ContentControlProtocol> *contentView;
    ToolbarView                    *toolbarView;
    MenubarView                    *menubarView;
    AnnotationView                 *annotationView;
    WhitepaperController           *whitepaperController; 
    int currentContentScreen;
}
- (void)discardToolbar;
- (void)fadeOutToAction:(void(^)(void))action;
- (void)fadeIn;
- (void)loadContent;
@end

@implementation MasterController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        // Content management
        contentProvider = [[SlideProvider alloc] init];
        contentProvider.delegate = self;
        currentContentScreen = 0;
        
        // Whitepaper controller
        whitepaperController = [[WhitepaperController alloc] init];
        [self addChildViewController:whitepaperController];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[Viewport screenArea]];
    // Initialization code
    self.view.backgroundColor = [UIColor purpleColor];
    
    // Subviews
    toolbarView = [[ToolbarView alloc] init];
    menubarView = [[MenubarView alloc] init];
    contentView = [contentProvider viewForDocumentAtIndex:currentContentScreen];
    
    menubarView.frame = CGRectMake(0, self.view.frame.size.height - menubarView.image.size.height,
                                   menubarView.image.size.width, menubarView.image.size.height);
    contentView.frame = CGRectMake(0, 0,
                                   self.view.frame.size.width, self.view.frame.size.height - menubarView.bounds.size.height);
    [self.view addSubview:contentView];
    [self.view addSubview:menubarView];
    
    // Annotations
    annotationView = [[AnnotationView alloc] initWithFrame:contentView.frame andMasterView:[contentView getContentSubview]];
    [self.view addSubview:annotationView];
    
    // Delegation
    toolbarView.navigationDelegate  = self;
    toolbarView.toolControlDelegate = self;
    
    // Gestures & view for toolbar
    UIView *gestureView = [[UIView alloc] initWithFrame:toolbarView.frame];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [gestureView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [gestureView addGestureRecognizer:swipeDown];
    
    [gestureView addSubview:toolbarView];

    [self.view addSubview:gestureView];
    
    // Navigation gestures
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeLeft setNumberOfTouchesRequired:2];
    [contentView addGestureRecognizer:swipeLeft];
    swipeLeft.delegate = self;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeRight setNumberOfTouchesRequired:2];
    [contentView addGestureRecognizer:swipeRight];
    swipeRight.delegate = self;

    // Hide content views until content is loaded
    contentView.alpha = 0.0;
    annotationView.alpha = 0.0;
}

- (void)fadeOutToAction:(void(^)(void))action
{
    [UIView animateWithDuration:FADE_DURATION
                     animations:^{
                         contentView.alpha    = 0.0;
                         annotationView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         action();
                     }];
}

- (void)fadeIn
{
    [UIView animateWithDuration:FADE_DURATION
                     animations:^{
                         contentView.alpha    = 1.0;
                         annotationView.alpha = 1.0;

                     }];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    
    return NO;
}

- (void)discardToolbar
{
    [toolbarView performSelector:@selector(hide) withObject:nil afterDelay:0.25];
}

// Document navigation

- (void)saveAnnotations
{
    NSDictionary *annotations = [NSDictionary dictionaryWithObjectsAndKeys:
                                 annotationView.penPaths,    kPenPathsKey,
                                 annotationView.markerPaths, kMarkerPathsKey,
                                 nil];
    [contentProvider setAnnotations:annotations forDocumentAtIndex:currentContentScreen];
}

- (void)loadAnnotations
{
    NSDictionary *annotations = [contentProvider annotationsForDocumentAtIndex:currentContentScreen];
    annotationView.penPaths    = [annotations objectForKey:kPenPathsKey];
    annotationView.markerPaths = [annotations objectForKey:kMarkerPathsKey];
}

- (void)loadContent
{
    [self fadeOutToAction:^{
        [self loadAnnotations];
        contentView = [contentProvider viewForDocumentAtIndex:currentContentScreen];
    }];
}

- (void)loadPreviousDocument
{
    [self saveAnnotations];
    currentContentScreen = MAX(--currentContentScreen, 0);
    [self loadContent];
}

- (void)loadNextDocument
{
    [self saveAnnotations];
    currentContentScreen = MIN(++currentContentScreen, [contentProvider numberOfDocuments] - 1);
    [self loadContent];
}

- (void)loadFirstDocument
{
    [self saveAnnotations];
    currentContentScreen = 0;
    [self loadContent];
}

- (void)loadLastDocument
{
    [self saveAnnotations];
    currentContentScreen = [contentProvider numberOfDocuments] - 1;
    [self loadContent];
}

// Delegation
- (void)contentViewDidFinishLoad
{
    [toolbarView contentChanged];
    [menubarView contentChanged];
    
    if (currentContentScreen == 0) {
        [toolbarView contentStarted];
        [menubarView contentStarted];
    }
    else if (currentContentScreen == [contentProvider numberOfDocuments] - 1) {
        [toolbarView contentFinished];
        [menubarView contentFinished];
    }
         
    [self fadeIn];
    [self discardToolbar];
}

- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, toolbarView.frame.size.width, toolbarView.frame.size.height), point))
        [toolbarView hide];
}

- (void)swipeDown:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, toolbarView.frame.size.width, toolbarView.frame.size.height), point))
        [toolbarView show];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    [self loadNextDocument];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    [self loadPreviousDocument];
}

- (void)tap:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, toolbarView.frame.size.width, toolbarView.frame.size.height), point))
        [toolbarView toggle];
}

- (void)menubarViewDidPressApertura
{
    [self loadFirstDocument];
}

- (void)menubarViewDidPressCierre
{
    [self loadLastDocument];
}

- (void)menubarViewDidPressEstudios
{
    whitepaperController.view.frame = contentView.frame;
    [self.view addSubview:whitepaperController.view];
}

- (void)menubarViewDidPressIPP
{
    NSLog(@"IPP");
}

- (void)toolbarViewDidPressBack
{
    [self loadPreviousDocument];
}

- (void)toolbarViewDidPressForward
{
    [self loadNextDocument];
}

- (void)toolbarViewDidPressPlay 
{
    [self fadeOutToAction:^{
        [contentView playAction];
        [self discardToolbar];
    }];
}

- (void)toolbarViewDidSelectPen
{
    [annotationView startDrawing:PathTypePen];
}

- (void)toolbarViewDidSelectMarker
{
    [annotationView startDrawing:PathTypeMarker];
}

- (void)toolbarViewDidSelectEraser
{
    [annotationView startDrawing:PathTypeEraser];
}

- (void)toolbarViewDidDeselectTool
{
    [annotationView finishDrawing];
    [self discardToolbar];
}

@end
    

