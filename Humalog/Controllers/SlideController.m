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
#define STACK_OFFSET  -15

@interface SlideController () {
@private
    SlideProvider                  *slideProvider;
    AnnotationView                 *annotationView;
    UIView<ContentControlProtocol> *contentView;
    ThumbnailStackView             *stackView;
    NSUInteger                     currentSlide;
    NSUInteger                     currentCategoryIndex;
    NSUInteger                     stackCategoryIndex;
    NSUInteger                     previousIndex;
    enum NavigationPosition        navigationPosition;
    BOOL                           drawThumbnails;
}
@property (nonatomic, assign) enum NavigationPosition navigationPosition;
@property (nonatomic, assign) NSUInteger currentCategoryIndex;
- (void)updateNavigationPosition;
@end

@implementation SlideController
@synthesize navigationPosition, currentCategoryIndex;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        drawThumbnails = YES;
        slideProvider = [[SlideProvider alloc] init];
        slideProvider.delegate = self;
    }
    return self;
}

- (void)loadView
{
    currentSlide = 0;
    
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
    NSUInteger stackWidth = [slideProvider previewForDocumentAtIndex:0].bounds.size.width + 64.0;
    stackView = [[ThumbnailStackView alloc] initWithFrame:CGRectMake(0, 0, stackWidth, 0)];
    stackView.delegate   = self;
    stackView.dataSource = self;
    stackView.hidden = YES;
    stackView.alpha = 0.0;
    stackView.baseline = CGPointMake(self.view.center.x, self.view.bounds.size.height);
    [self.view addSubview:stackView];
        
    // Hide content views until content is loaded
    contentView.alpha    = 0.0;
    annotationView.alpha = 0.0;        
}

- (void)viewWillAppear:(BOOL)animated
{
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
    
    self.currentCategoryIndex = [slideProvider categoryIndexForDocumentAtIndex:currentSlide];
}

- (void)loadContent
{
    [stackView hide];
    
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
//    return [slideProvider numberOfDocuments];
    NSUInteger num = [slideProvider rangeForCategoryIndex:stackCategoryIndex].length;
    return num;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view
{
    NSUInteger documentIndex = [slideProvider rangeForCategoryIndex:stackCategoryIndex].location + index;
    
    // Title
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    title.text = [slideProvider titleForDocumentAtIndex:documentIndex];
    title.font = [UIFont boldSystemFontOfSize:15.0];
    title.frame = CGRectMake(0, 0, carousel.bounds.size.width - 16.0, title.font.lineHeight * 2.0);
    title.textAlignment = UITextAlignmentCenter;
    title.lineBreakMode = UILineBreakModeWordWrap;
    title.numberOfLines = 0;
    
    // Container
    UIView *container = [[UIView alloc] init];
//    container.backgroundColor = [UIColor grayColor];
    
    // Hilight selected
    if (currentSlide == documentIndex) {
        container.layer.shadowOpacity = 1.0;
        container.layer.shadowRadius = 10.0;
        container.layer.shadowColor = [UIColor whiteColor].CGColor;
        title.textColor = [UIColor whiteColor];
    }
    
    if (!drawThumbnails) {
        container.frame = title.frame;
        [container addSubview:title];
        
        // HR
        if (index < carousel.numberOfItems - 1) {
            UIView *hr = [[UIView alloc] initWithFrame:CGRectMake(0, title.bounds.size.height + 4.0,
                                                                  title.bounds.size.width - 12.0, 1)];
            hr.center = CGPointMake(title.center.x, hr.center.y);
            hr.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
            hr.opaque = YES;        
            [container addSubview:hr];
        }
        return container;
    }
    
    // Image
    UIView *thumb = [slideProvider previewForDocumentAtIndex:documentIndex];    
    thumb.clipsToBounds = YES;
    thumb.layer.cornerRadius = 4.0f;
    
    // Container
    container.frame = CGRectInset(thumb.frame, 0, -title.bounds.size.height / 2.0);
    [container addSubview:thumb];
    title.frame = CGRectOffset(title.frame, 0, thumb.bounds.size.height);
    title.center = CGPointMake(thumb.center.x, title.center.y);
    [container addSubview:title];
    
    return container;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 8.0 + [UIFont boldSystemFontOfSize:15.0].lineHeight * 2.0 + (drawThumbnails? [slideProvider previewForDocumentAtIndex:0].bounds.size.height : 0.0);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return NO;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 7;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    // Feed document view
    currentSlide = [slideProvider rangeForCategoryIndex:stackCategoryIndex].location + index;
    [carousel reloadItemAtIndex:previousIndex animated:YES];
    [carousel reloadItemAtIndex:index animated:YES];
    previousIndex = index;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// Tool & Nav
- (void)menubarViewDidSelectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index
{
    stackCategoryIndex = index;
//    currentSlide = [slideProvider rangeForCategoryIndex:index].location;
//    [self loadContent];
    
    // Move stack
    stackView.baseline = CGPointMake(button.center.x, self.view.bounds.size.height + STACK_OFFSET);
    [stackView reloadData];
    [stackView show];
}

- (void)menubarViewDidDeselectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index
{
    // Hide stack
    [stackView hide];
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
    if ([self.parentViewController respondsToSelector:@selector(loadWhitepapers)])
        [self.parentViewController performSelector:@selector(loadWhitepapers)];
}

//- (void)menubarViewDidPressIPP
//{
//    NSLog(@"IPP");
//}

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

- (void)toolbarViewDidPressThumbnailsLeft
{
    drawThumbnails = NO;
    [stackView reloadData];
}

- (void)toolbarViewDidPressThumbnailsBottom
{
    drawThumbnails = YES;
    [stackView reloadData];
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
