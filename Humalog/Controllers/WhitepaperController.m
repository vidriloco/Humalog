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
    return [whitepaperProvider viewForDocumentAtIndex:index];
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
    self.view = [whitepaperProvider viewForDocumentAtIndex:index];
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIView *grayView = [[UIView alloc] init];
    grayView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.88];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:[Viewport screenArea]];
    carousel.type = iCarouselTypeRotary;
    carousel.delegate   = self;
    carousel.dataSource = self;
    
    [grayView addSubview:carousel];
    self.view = grayView;
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
