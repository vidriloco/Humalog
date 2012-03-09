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

// Private
@interface MasterController() {
    ContentProvider                *contentProvider;
    UIView<ContentControlProtocol> *contentView;
    ToolbarView                    *toolbarView;
}
- (void)discardToolbar;
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
        currentContentScreen = 2;
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
    self.view.backgroundColor = [UIColor purpleColor];
    
    // Subviews
    toolbarView = [[ToolbarView alloc] init];
    MenubarView *menubarView = [[MenubarView alloc] init];
    contentView = [contentProvider viewForItemAtIndex:currentContentScreen];
    
    menubarView.frame = CGRectMake(0, self.view.frame.size.height - menubarView.image.size.height, menubarView.image.size.width, menubarView.image.size.height);
    contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - menubarView.bounds.size.height);
    
    [self.view addSubview:contentView];
    [self.view addSubview:menubarView];
//    [self.view addSubview:toolbarView];
    
    // Delegation
    toolbarView.navigationDelegate = self;
    
    // Gestures
    UIView *gestureView = [[UIView alloc] initWithFrame:toolbarView.frame];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [gestureView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [gestureView addGestureRecognizer:swipeDown];
    
    [gestureView addSubview:toolbarView];

    [self.view addSubview:gestureView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self discardToolbar];
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

- (void)discardToolbar {
    [toolbarView performSelector:@selector(hide) withObject:nil afterDelay:0.5];
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
    currentContentScreen = MAX(--currentContentScreen, [contentProvider first]);
    contentView = [contentProvider viewForItemAtIndex:currentContentScreen];
    [self discardToolbar];
}

- (void)toolbarViewDidPressForward
{
    currentContentScreen = MIN(++currentContentScreen, [contentProvider count]);
    contentView = [contentProvider viewForItemAtIndex:currentContentScreen];
    [self discardToolbar];
}

- (void)toolbarViewDidPressPlay 
{
    [contentView playAction];
    [self discardToolbar];
}
@end
    

