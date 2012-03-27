//
//  WhitepaperController.m
//  Humalog
//
//  Created by Workstation on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WhitepaperController.h"
#import "WhitepaperProvider.h"
#import "Viewport.h"
#import "AnnotationView.h"

@interface WhitepaperController () {
    WhitepaperProvider *whitepaperProvider;
    AnnotationView     *annotationView;
    UIView             *documentView;
}
@end

@implementation WhitepaperController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        whitepaperProvider = [[WhitepaperProvider alloc] init];
    }
    return self;
}

#pragma mark - iCarousel delegate methods

// Data source
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [whitepaperProvider numberOfDocuments];
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view
{
    UIView *preview = [whitepaperProvider previewForDocumentAtIndex:index];
    preview.clipsToBounds = YES;
    preview.layer.cornerRadius = 30.0;
    return preview;
}

// Delegate
- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return kPreviewSize.size.width;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    documentView = [whitepaperProvider viewForDocumentAtIndex:index];
    documentView.frame = self.view.bounds;
    documentView.alpha = 0.0;
    [self.view addSubview:documentView];
    [UIView animateWithDuration:1.0
                     animations:^{
                         documentView.alpha = 1.0;
                     }];
}

#pragma mark - Menubar delegate methods
- (void)menubarViewDidPressEstudios
{
    [documentView removeFromSuperview];
}

- (void)menubarViewDidPressApertura
{
    if ([self.parentViewController respondsToSelector:@selector(loadSlides)])
        [self.parentViewController performSelector:@selector(loadSlides)];
    
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[Viewport contentArea]];
    self.view.backgroundColor = [UIColor purpleColor];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    carousel.type = iCarouselTypeRotary;
    carousel.delegate   = self;
    carousel.dataSource = self;
    
    [self.view addSubview:carousel];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
