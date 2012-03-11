//
//  MasterController.m
//  Humalog
//
//  Created by Workstation on 3/1/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "ContentControlProtocol.h"
#import "MasterController.h"
#import "ContentProvider.h"
#import "ToolbarView.h"
#import "MenubarView.h"
#import "AnnotationView.h"

#define FADE_DURATION 0.5

// Private
@interface MasterController() {
    ContentProvider                *contentProvider;
    UIView<ContentControlProtocol> *contentView;
    ToolbarView                    *toolbarView;
    AnnotationView                 *annotationView;
}
- (void)discardToolbar;
- (void)fadeOut;
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
        contentProvider = [[ContentProvider alloc] init];
        contentProvider.delegate = self;
        currentContentScreen = [contentProvider first];
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
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)]; //[[UIScreen mainScreen] bounds]];
    // Initialization code
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Subviews
    toolbarView = [[ToolbarView alloc] init];
    MenubarView *menubarView = [[MenubarView alloc] init];
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
    toolbarView.navigationDelegate = self;
    
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
    
    // Hide content views until content is loaded
    contentView.alpha = 0.0;
    annotationView.alpha = 0.0;
}

- (void)fadeOut
{
    [UIView animateWithDuration:FADE_DURATION
                     animations:^{
                         contentView.alpha = 0.0;
                         annotationView.alpha = 0.0;
                     }];
}

- (void)fadeIn
{
    [UIView animateWithDuration:FADE_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         contentView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

    [UIView animateWithDuration:FADE_DURATION
                          delay:FADE_DURATION / 2.0
                        options:0
                     animations:^{
                         annotationView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
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
    [self fadeOut];
    [self loadAnnotations];
    contentView = [contentProvider viewForDocumentAtIndex:currentContentScreen];
}

// Delegation

- (void)contentViewDidFinishLoad
{
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

- (void)tap:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, toolbarView.frame.size.width, toolbarView.frame.size.height), point))
        [toolbarView toggle];
}

- (void)toolbarViewDidPressBack
{
    [self saveAnnotations];
    currentContentScreen = MAX(--currentContentScreen, [contentProvider first]);
    [self loadContent];
}

- (void)toolbarViewDidPressForward
{
    [self saveAnnotations];
    currentContentScreen = MIN(++currentContentScreen, [contentProvider count]);
    [self loadContent];
}

- (void)toolbarViewDidPressPlay 
{
    [self fadeOut];
    [contentView playAction];
    [self discardToolbar];
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
    

