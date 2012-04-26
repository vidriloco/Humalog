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
    NSArray             *whitepaperList;
    NSMutableDictionary *previewList;
}
@end

@implementation WhitepaperProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        whitepaperList = [NSArray array];
        previewList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) loadContent:(NSArray *)pdfs
{
    whitepaperList = pdfs;
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Save image
    [self performSelector:@selector(generatePreview) withObject:nil afterDelay:1.0]; 
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSNumber *indexNumber = [NSNumber numberWithUnsignedInteger:index];
    UIImageView *imageView = [previewList objectForKey:indexNumber];
    if (imageView)
        return imageView;
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:[whitepaperList objectAtIndex:index] ofType:@"pdf"];
    imageView = [[UIImageView alloc] initWithImage:[self generatePreviewFor:fileName]];
    [previewList setObject:imageView forKey:indexNumber];
    return imageView;
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
