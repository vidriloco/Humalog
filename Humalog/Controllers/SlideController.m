//
//  SlideController.m
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlideController.h"
#import "SlideProvider.h"
#import "AnnotationView.h"
#import "Viewport.h"
#import "ThumbnailStackView.h"

#define FADE_DURATION 0.25

@interface SlideController () {
@private
    SlideProvider                  *slideProvider;
    AnnotationView                 *annotationView;
    UIView<ContentControlProtocol> *contentView;
    ThumbnailStackView             *stackView;
    int currentSlide;
    enum NavigationPosition        navigationPosition;
}
@property (nonatomic, assign) enum NavigationPosition navigationPosition;
- (void)updateNavigationPosition;
@end

@implementation SlideController
@synthesize navigationPosition;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        slideProvider = [[SlideProvider alloc] init];
        slideProvider.delegate = self;
        currentSlide = 0;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[Viewport contentArea]];
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor purpleColor];
    
    contentView = [slideProvider viewForDocumentAtIndex:currentSlide];
    contentView.frame = self.view.frame;
    [self.view addSubview:contentView];
    
    // Annotations
    annotationView = [[AnnotationView alloc] initWithFrame:contentView.frame andMasterView:[contentView getContentSubview]];
    [self.view addSubview:annotationView];
    
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
    
    // Thumbnail stack
    NSUInteger stackWidth = [slideProvider previewForDocumentAtIndex:0].bounds.size.width + 30;
    stackView = [[ThumbnailStackView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, stackWidth, self.view.frame.size.height), 0, 30)];
    stackView.delegate   = self;
    stackView.dataSource = self;
    [self.view addSubview:stackView];
    
    // Hide content views until content is loaded
    contentView.alpha    = 0.0;
    annotationView.alpha = 0.0;
    
    [self updateNavigationPosition];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Eyecandy
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

#pragma mark - Document management

- (void)saveAnnotations
{
    NSDictionary *annotations = [NSDictionary dictionaryWithObjectsAndKeys:
                                 annotationView.penPaths,    kPenPathsKey,
                                 annotationView.markerPaths, kMarkerPathsKey,
                                 nil];
    [slideProvider setAnnotations:annotations forDocumentAtIndex:currentSlide];
}

- (void)loadAnnotations
{
    NSDictionary *annotations  = [slideProvider annotationsForDocumentAtIndex:currentSlide];
    annotationView.penPaths    = [annotations objectForKey:kPenPathsKey];
    annotationView.markerPaths = [annotations objectForKey:kMarkerPathsKey];
}

- (void)updateNavigationPosition
{
    // Update navigation position status
    if (currentSlide == 0)
        self.navigationPosition = NavigationPositionFirstDocument;
    
    else if (currentSlide == [slideProvider numberOfDocuments] - 1)
        self.navigationPosition = NavigationPositionLastDocument;
    
    else self.navigationPosition = NavigationPositionOtherDocument;
    
    [stackView scrollToItemAtIndex:currentSlide animated:YES];
}

- (void)loadContent
{
    [self fadeOutToAction:^{
        [self loadAnnotations];
        contentView = [slideProvider viewForDocumentAtIndex:currentSlide];
    }];
    [self updateNavigationPosition];
}

- (void)loadPreviousDocument
{
    [self saveAnnotations];
    currentSlide = MAX(--currentSlide, 0);
    [self loadContent];
}

- (void)loadNextDocument
{
    [self saveAnnotations];
    currentSlide = MIN(++currentSlide, [slideProvider numberOfDocuments] - 1);
    [self loadContent];
}

- (void)loadFirstDocument
{
    [self saveAnnotations];
    currentSlide = 0;
    [self loadContent];
}

- (void)loadLastDocument
{
    [self saveAnnotations];
    currentSlide = [slideProvider numberOfDocuments] - 1;
    [self loadContent];
}

#pragma mark - Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [slideProvider numberOfDocuments];
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view
{
    UIView *thumb = [slideProvider previewForDocumentAtIndex:index];
    thumb.clipsToBounds = YES;
    thumb.layer.cornerRadius = 8.0f;
//    if (carousel.currentItemIndex == index) {
//        thumb.layer.borderColor = [UIColor purpleColor].CGColor;
//        thumb.layer.borderWidth = 3.0f;
//    } else {
//        thumb.layer.borderWidth = 0.0;
//    }
    return thumb;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return [slideProvider previewForDocumentAtIndex:0].bounds.size.height + 16.0f;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return NO;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 9;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    // Feed document view
    currentSlide = index;
    [self loadContent];
}

- (void)contentViewDidFinishLoad
{
    [self fadeIn];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    [self loadNextDocument];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    [self loadPreviousDocument];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// Tool & Nav

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
    //    whitepaperController.view.frame = contentView.frame;
    //    [self.view addSubview:whitepaperController.view];
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
}

@end
