//
//  ContentController.m
//  Humalog
//
//  Created by Workstation on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentController.h"
#import "SlideProvider.h"
#import "AnnotationView.h"
#import "Viewport.h"
#import "ThumbnailStackView.h"
#import "WhitepaperProvider.h"
#import "Brand.h"
#import "GANTracker.h"

#define FADE_DURATION 0.5
#define STACK_OFFSET  -15

@interface ContentController () {
@private
    SlideProvider                  *slideProvider;
    WhitepaperProvider             *whitepaperProvider;
    AnnotationView                 *annotationView;
    UIView<ContentControlProtocol> *contentView;
    ThumbnailStackView             *stackView;
    iCarousel                      *rotaryCarousel;
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

@implementation ContentController
@synthesize navigationPosition, currentCategoryIndex;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        drawThumbnails = YES;
        
        slideProvider = [[SlideProvider alloc] init];
        slideProvider.delegate = self;
        
        whitepaperProvider = [[WhitepaperProvider alloc] init];
        whitepaperProvider.delegate = self;
        
        currentCategoryIndex = 0;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"resources/backs/"];
    NSString *brand = [Brand sharedInstance].brandName;
    brand = [brand stringByAppendingString:@".jpg"];
    brand = [brand lowercaseString];
    currentSlide = 0;
    
    self.view = [[UIView alloc] initWithFrame:[Viewport contentArea]];
    self.view.opaque = YES;
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:
                                 [UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:brand]]];

    NSLog(@"%@",[newDir stringByAppendingPathComponent:brand]);

    contentView = [slideProvider viewForDocumentAtIndex:currentSlide];
    contentView.frame = self.view.frame;
    [self.view addSubview:contentView];
    
    // Annotations
    annotationView = [slideProvider annotationViewForDocumentAtIndex:currentSlide];
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
    
    // Document carousel
    rotaryCarousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    rotaryCarousel.backgroundColor = [UIColor underPageBackgroundColor];
    rotaryCarousel.type = iCarouselTypeRotary;
    rotaryCarousel.delegate   = self;
    rotaryCarousel.dataSource = self;
    rotaryCarousel.hidden = YES;
    
    [self.view addSubview:rotaryCarousel];
        
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

- (void)hideCarousels
{
    [stackView hide];
    [UIView animateWithDuration:FADE_DURATION
                     animations:^{
                         rotaryCarousel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         rotaryCarousel.hidden = YES;
                     }];
}

- (void)loadContent
{
    [self hideCarousels];
    
    [self fadeOutToAction:^{
        [contentView removeFromSuperview];
        contentView = [slideProvider viewForDocumentAtIndex:currentSlide];
        [self.view insertSubview:contentView belowSubview:annotationView];

        [annotationView removeFromSuperview];
        annotationView = [slideProvider annotationViewForDocumentAtIndex:currentSlide];
        [self.view insertSubview:annotationView aboveSubview:contentView];
    }];
    [self updateNavigationPosition];
    
    // Tracker
    [self registerGA:TRUE withString:nil];
}

- (void)loadCustomContentWithProvider:(id<AnnotationDataSource, DocumentDataSource>)someProvider
                     andDocumentIndex:(NSUInteger)index;
{
    [self hideCarousels];
    
    [self fadeOutToAction:^{
        [contentView removeFromSuperview];
        contentView = [someProvider viewForDocumentAtIndex:index];
        [self.view insertSubview:contentView belowSubview:annotationView];
        
        [annotationView removeFromSuperview];
        annotationView = [someProvider annotationViewForDocumentAtIndex:index];
        [self.view insertSubview:annotationView aboveSubview:contentView];
    }];
    
    self.navigationPosition = NavigationPositionUndefined;
    self.currentCategoryIndex = 99;
    annotationView.masterView = [contentView contentSubview];
    
    // Tracker (Note that Custom = PDF for now, it may change in the future)
    [self registerGA:NO withString:[whitepaperProvider.whitepaperList objectAtIndex:index]];
}

- (void)registerGA:(BOOL)isSlide withString:(NSString *)string
{
    NSError *error;
    
    NSString *cadena = [Brand sharedInstance].brandName;
    
    if (isSlide && string == nil) {
        NSString *slide = [[[NSUserDefaults standardUserDefaults] objectForKey:@"slides_preference"] objectAtIndex:currentSlide];
        cadena = [cadena stringByAppendingPathComponent:slide];
    } else if (!isSlide&&string != nil) {
        cadena = [cadena stringByAppendingPathComponent:[@"PDF/" stringByAppendingString:string]];
    } else {
        cadena = [cadena stringByAppendingPathComponent:string];
    }
    if (![[GANTracker sharedTracker] trackPageview:cadena
                                         withError:&error]) {
        // Handle error here
    }
}


- (void)loadPreviousDocument
{
    currentSlide = MAX(--currentSlide, 0);
    [self loadContent];
}

- (void)loadNextDocument
{
    currentSlide = MIN(++currentSlide, [slideProvider numberOfDocuments] - 1);
    [self loadContent];
}

- (void)loadFirstDocument
{
    currentSlide = 0;
    [self loadContent];
}

- (void)loadLastDocument
{
    currentSlide = [slideProvider numberOfDocuments] - 1;
    [self loadContent];
}

- (void)loadSpecial
{
    currentSlide = [slideProvider numberOfDocuments] - 2;
    [self loadContent];
    [self registerGA:TRUE withString:@"Especial"];
}

#pragma mark - iCarousel data source methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    // Document carousel
    if (carousel == rotaryCarousel) {
        return [whitepaperProvider numberOfDocuments];
    }

    // Slide carousel
    NSUInteger num = [slideProvider rangeForCategoryIndex:stackCategoryIndex].length;
    return num;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view
{
    // Document carousel
    if (carousel == rotaryCarousel) {
        UIView *preview = [whitepaperProvider previewForDocumentAtIndex:index];
        preview.clipsToBounds = YES;
        preview.layer.cornerRadius = 10.0;
        return preview;
    }
    
    // Slide carousel
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

    
    UILabel *separator = [[UILabel alloc] init];    
    separator.frame = CGRectMake(0, 0, 150.0, 1.0); 
    
    // Container
    UIView *container = [[UIView alloc] init];
    
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
    
    // Thumbnail
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
    // Document carousel
    if (carousel == rotaryCarousel) {
        return kPreviewSize.size.width;
    }
    
    // Slide carousel
    return 8.0 + [UIFont boldSystemFontOfSize:15.0].lineHeight * 2.0 + (drawThumbnails? [slideProvider previewForDocumentAtIndex:0].bounds.size.height : 0.0);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return (carousel == rotaryCarousel);
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    // Document carousel
    if (carousel == rotaryCarousel) {
        return [whitepaperProvider numberOfDocuments];
    }
    
    // Slide carousel
    return 7;
}

#pragma mark - iCarousel delegate methods

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    // Document carousel
    if (carousel == rotaryCarousel) {
        // Only the front element is selectable
        if (carousel.currentItemIndex != index)
            return;
        
        [self loadCustomContentWithProvider:whitepaperProvider
                           andDocumentIndex:index];
        
        return;
    }
    
    // Slide carousel
    // Feed document view
    currentSlide = [slideProvider rangeForCategoryIndex:stackCategoryIndex].location + index;
    [carousel reloadItemAtIndex:previousIndex animated:YES];
    [carousel reloadItemAtIndex:index animated:YES];
    previousIndex = index;
    [self loadContent];
}

#pragma mark - Misc delegate methods

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

#pragma mark - Toolbar delegate methods

- (void)menubarViewDidSelectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index
{
    //currentCategoryIndex = index;
//    NSString *category = [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"] objectAtIndex:index];
    NSString *category = [[Brand sharedInstance].categories objectAtIndex:index];
    NSRange match = [category rangeOfString:@","];
    NSString *string2 = [category substringFromIndex:match.location + 1];

    stackCategoryIndex = index;
    
    if ([string2 intValue] == 1) {
        currentSlide = [slideProvider rangeForCategoryIndex:index].location;
        [self loadContent];
    } else {
        // Move stack
        stackView.baseline = CGPointMake(button.center.x, self.view.bounds.size.height + STACK_OFFSET);
        [stackView reloadData];
        [stackView show];
    }
}

- (void)menubarViewDidDeselectCategoryButton:(UIButton *)button withIndex:(NSUInteger)index
{
    // Hide stack
    [stackView hide];
}

- (void)menubarViewDidPressApertura
{
    currentCategoryIndex = 99;
    [self loadFirstDocument];
}

- (void)menubarViewDidPressCierre
{
    currentCategoryIndex = 99;
    [self loadLastDocument];
}

- (void)whitepaperDisplayAction
{
    if ([whitepaperProvider numberOfDocuments] <= 1) {
        [self loadCustomContentWithProvider:whitepaperProvider
                           andDocumentIndex:0];
        return;
    }
 
    [rotaryCarousel reloadData];
    rotaryCarousel.hidden = NO;
    [UIView animateWithDuration:FADE_DURATION
                     animations:^{
                         rotaryCarousel.alpha = 1.0;
                     }];

}

- (void)menubarViewDidPressEstudios
{
    whitepaperProvider.whitepaperList = [Brand sharedInstance].studies;
    [self whitepaperDisplayAction];
}

- (void)menubarViewDidPressReferencias
{
    whitepaperProvider.whitepaperList = [Brand sharedInstance].references;
    [self whitepaperDisplayAction];
}

- (void)menubarViewDidPressIPP
{
    whitepaperProvider.whitepaperList = [Brand sharedInstance].IPPs;
    [self whitepaperDisplayAction];
}

- (void)menubarViewDidPressEspecial
{
    [self loadSpecial];
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
