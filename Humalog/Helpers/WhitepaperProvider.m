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
#import "Brand.h"
#import "Viewport.h"

@interface WhitepaperProvider() {
    NSMutableDictionary *documentAnnotations;
    NSMutableDictionary *previewList;
    WebContentView      *webView;
    AnnotationView      *annotationView;
    NSString            *previousKey;
}
@end

@implementation WhitepaperProvider
@synthesize delegate, whitepaperList;

- (id)init
{
    if ((self = [super init])) {
        previewList    = [NSMutableDictionary dictionary];
        webView        = [[WebContentView alloc] initWithFrame:[Viewport contentArea]];
        webView.scalesPageToFit = YES;
        webView.delegate        = self;
        
        annotationView = [[AnnotationView alloc] initWithFrame:webView.frame];
        annotationView.masterView = [webView contentSubview];
        
        documentAnnotations = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Previews

- (UIImage *)generatePreviewFor:(NSString*)fileName
{    
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:fileName]);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, 1);
    CGRect tmpRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    
    CGFloat scale = kPreviewSize.size.width / tmpRect.size.width;
    CGRect rect = kPreviewSize;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // White BG
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);

    CGContextTranslateCTM(context, 0, tmpRect.size.height * scale);
    CGContextScaleCTM(context, scale, -scale);
    CGContextDrawPDFPage(context, pdfPage);
    UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPDFDocumentRelease(pdf);
    return pdfImage;
}

- (NSString *)pathForDocumentAtIndex:(NSUInteger)index
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"slides/"];    
    NSString *path = [newDir stringByAppendingPathComponent:[self.whitepaperList objectAtIndex:index]];
    return [path stringByAppendingString:@".pdf"];
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString    *key = [whitepaperList objectAtIndex:index];
    UIImageView *imageView = [previewList objectForKey:key];
    if (imageView)
        return imageView;
    
    NSString *fileName = [self pathForDocumentAtIndex:index];
    imageView = [[UIImageView alloc] initWithImage:[self generatePreviewFor:fileName]];
    [previewList setObject:imageView forKey:key];
    return imageView;
}

- (NSUInteger)numberOfDocuments
{
    return [self.whitepaperList count];
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    NSString *path = [self pathForDocumentAtIndex:index];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
    // Tracker stuff
    NSString *pdfName = [[whitepaperList objectAtIndex:index] stringByAppendingString:@"_PDF"];
    [Brand trackContentWithType:HumalogContentReportTypePDF andName:pdfName];
    
    return webView;
}

- (AnnotationView *)annotationViewForDocumentAtIndex:(NSUInteger)index
{
    // Save previous
    NSDictionary *annotations = [NSDictionary dictionaryWithObjectsAndKeys:
                                 annotationView.markerPaths, kMarkerPathsKey,
                                 annotationView.penPaths,    kPenPathsKey,
                                 nil];
    
    if (previousKey)
        [documentAnnotations setObject:annotations forKey:previousKey];
    
    // Load new
    annotations = [documentAnnotations objectForKey:[self.whitepaperList objectAtIndex:index]];
    annotationView.penPaths    = [annotations objectForKey:kPenPathsKey]; 
    annotationView.markerPaths = [annotations objectForKey:kMarkerPathsKey]; 
    previousKey = [self.whitepaperList objectAtIndex:index];
    
    return annotationView;
}

- (void)loadStudies
{
    whitepaperList = [Brand sharedInstance].studies;

    // Tracker stuff
    NSString *pdfName = @"Estudios_PDF";
    [Brand trackContentWithType:HumalogContentReportTypePDFCategory andName:pdfName];
}

- (void)loadIPPs
{
    whitepaperList = [Brand sharedInstance].IPPs;
    
    // Tracker stuff
    NSString *pdfName = @"IPP_PDF";
    [Brand trackContentWithType:HumalogContentReportTypePDFCategory andName:pdfName];
}

- (void)loadReferences
{
    whitepaperList = [Brand sharedInstance].references;
    
    // Tracker stuff
    NSString *pdfName = @"Referencias_PDF";
    [Brand trackContentWithType:HumalogContentReportTypePDFCategory andName:pdfName];
}

#pragma mark - UIWebView delegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"ERROR: %@", [error description]);
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(delay) withObject:nil afterDelay:0.5];
}

- (void)delay
{
    [self.delegate contentViewDidFinishLoad];
    webView.hidden = NO;
}

@end
