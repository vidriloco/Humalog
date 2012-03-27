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
#import "WhitepaperController.h"
#import "SlideController.h"
#import "Viewport.h"

#define FADE_DURATION 0.25

// Private
@interface MasterController() {
    UIView               *gestureView;
    ToolbarView          *toolbarView;
    MenubarView          *menubarView;
    WhitepaperController *whitepaperController; 
    SlideController      *slideController;
}
@end

@implementation MasterController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        // Slide controller
        slideController = [[SlideController alloc] init];
        [self addChildViewController:slideController];
        
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
    self.view.opaque = YES;
    
    // Subviews
    toolbarView = [[ToolbarView alloc] init];
    menubarView = [[MenubarView alloc] init];
    
    menubarView.frame = [Viewport menuArea];
    [self.view addSubview:menubarView];
    
    // Gestures & view for toolbar
    gestureView = [[UIView alloc] initWithFrame:toolbarView.bounds];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [gestureView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [gestureView addGestureRecognizer:swipeDown];
    
    [gestureView addSubview:toolbarView];

    [self.view addSubview:gestureView];
    
    [self loadSlides];
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

#pragma mark - Gesture control

- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, gestureView.bounds.size.width, gestureView.bounds.size.height), point))
        [toolbarView hide];
}

- (void)swipeDown:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, gestureView.bounds.size.width, gestureView.bounds.size.height), point))
        [toolbarView show];
}

- (void)tap:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(0, 0, gestureView.bounds.size.width, gestureView.bounds.size.height), point))
        [toolbarView toggle];
}

#pragma mark - Content control
- (void)loadSlides
{
    [whitepaperController.view removeFromSuperview];
    [self.view insertSubview:slideController.view belowSubview:gestureView];
    
    // Delegation
    toolbarView.delegate = slideController;
    menubarView.delegate = slideController;
    [toolbarView hide];
}

- (void)loadWhitepapers
{
    [slideController.view removeFromSuperview];
    [self.view insertSubview:whitepaperController.view belowSubview:gestureView];
    
    // Delegation
    toolbarView.delegate = whitepaperController;
    menubarView.delegate = whitepaperController;
    [toolbarView hide];
}

@end
    

