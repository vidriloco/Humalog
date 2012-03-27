//
//  PaperProvider.m
//  Humalog
//
//  Created by Workstation on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WhitepaperProvider.h"
#import "WebContentView.h"

@interface WhitepaperProvider() {
    NSArray *whitepaperList;
    NSMutableArray *previewList;
    UIWebView *preView;
    NSUInteger currentPreview;
}
@end

@implementation WhitepaperProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        whitepaperList = [NSArray arrayWithObjects:
                          @"ONSET and OFFSET study, 2009",
                          @"PLATO trial, 2009",
                          @"Wallentin Spanish",
                          nil];
        previewList = [NSMutableArray array];
        preView = [[UIWebView alloc] initWithFrame:kPreviewSize];
        preView.delegate = self;
        currentPreview = 0;
        
//        [self grabPreviews];
    }
    return self;
}

#pragma mark - Previews
- (void)grabPreviews
{
    if (currentPreview >= [self numberOfDocuments])
        return;
    
    NSString *fileName = [whitepaperList objectAtIndex:currentPreview];    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pdf"];
    [preView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (void)generatePreview
{    
    // Create a new render context of the UIView size, and set a scale so that the full stage will render to it
    UIGraphicsBeginImageContext(CGSizeMake(preView.bounds.size.width, preView.bounds.size.height));
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0f, 1.0f);
    
    // Render the stage to the new context
    [preView.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Get an image from the context
    UIImage* viewImage = 0;
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Kill the render context
    UIGraphicsEndImageContext();
    
    // Save the UIImageView
    [previewList addObject:[[UIImageView alloc] initWithImage:viewImage]];
    currentPreview++;
    
    NSLog(@"Made preview #%d", currentPreview);
    
    [self grabPreviews];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Save image
    [self performSelector:@selector(generatePreview) withObject:nil afterDelay:1.0]; 
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
//    return [previewList objectAtIndex:index];
    NSString *fileName = [[whitepaperList objectAtIndex:index] stringByAppendingString:@".png"];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
}

- (NSUInteger)numberOfDocuments
{
    return 3;
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    NSString *fileName = [whitepaperList objectAtIndex:index];    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pdf"];
    WebContentView *webView = [[WebContentView alloc] initWithFrame:kPreviewSize];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    return webView;
}

- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index
{
    return nil;
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index
{
    
}



@end
