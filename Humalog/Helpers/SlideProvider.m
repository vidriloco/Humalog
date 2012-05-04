//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "SlideProvider.h"
#import "WebContentView.h"
#import "Brand.h"

@interface SlideProvider() {
    NSMutableDictionary *documentAnnotations;
    NSArray             *documentTitles;
    NSArray             *categoriesAndIndices;
    WebContentView      *webContentView;
    AnnotationView      *annotationView;
    NSString            *brandName;
    NSUInteger          previousIndex;
}

@end

@implementation SlideProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        webContentView = [[WebContentView alloc] init];
        webContentView.delegate = self;
        webContentView.scalesPageToFit = NO;
        
        annotationView = [[AnnotationView alloc] initWithFrame:webContentView.frame];
        annotationView.masterView = [webContentView contentSubview];
        
        documentAnnotations = [NSMutableDictionary dictionary];
        
        NSArray *categories = [Brand sharedInstance].categories;
        NSArray *slides     = [Brand sharedInstance].slides;
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i = 0; i < [categories count]; ++i) {
            NSString *cadena = [categories objectAtIndex:i];
            
            NSRange match = [cadena rangeOfString:@","];
            NSString *string1 = [cadena substringToIndex:match.location];
            NSString *string2 = [cadena substringFromIndex:match.location + 1];
            
            [temp addObject:[NSValue valueWithRange:NSMakeRange([string1 intValue], [string2 intValue])]];
        }
        categoriesAndIndices = temp;
        documentTitles = slides;
    }
    
    return self;
}


- (NSUInteger)numberOfDocuments
{
    return [Brand sharedInstance].slides.count;
}

- (NSUInteger)numberOfCategories
{
    return [Brand sharedInstance].numberOfCategories;
}

- (NSString *)titleForDocumentAtIndex:(NSUInteger)index
{
    return [documentTitles objectAtIndex:index];
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"slides/"];    
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithUnsignedInt:index + 1] stringValue]];
    newDir = [newDir stringByAppendingPathComponent:slideName];
    NSMutableString *path = [NSMutableString string];
    slideName = [slideName stringByAppendingString:@".html"];
    [path appendString:[newDir stringByAppendingPathComponent:slideName]];

    
    if (!path)
        return nil;
    
    NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                        relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                  isDirectory: YES]];
    
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    webContentView.scalesPageToFit = YES;
    return webContentView;
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"resources/backs/"];
    NSString *brand = [Brand sharedInstance].brandName;
    brand = [brand lowercaseString];
    brand = [brand stringByAppendingString:@"_"];
    NSString *fileName = [[brand stringByAppendingString:[NSNumber numberWithUnsignedInt:index + 1].stringValue] stringByAppendingString:@".jpg"];

    return [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:fileName]]];
}

- (NSRange)rangeForCategoryIndex:(NSUInteger)categoryIndex
{
    return [[categoriesAndIndices objectAtIndex:categoryIndex] rangeValue];
}

- (NSUInteger)categoryIndexForDocumentAtIndex:(NSUInteger)documentIndex
{
    for (NSValue *value in categoriesAndIndices)
        if (NSLocationInRange(documentIndex, [value rangeValue]))
            return [categoriesAndIndices indexOfObject:value];
    
    return NSUIntegerMax;
}

- (AnnotationView *)annotationViewForDocumentAtIndex:(NSUInteger)index
{
    // Save previous
    NSDictionary *annotations = [NSDictionary dictionaryWithObjectsAndKeys:
                                 annotationView.markerPaths, kMarkerPathsKey,
                                 annotationView.penPaths,    kPenPathsKey,
                                 nil];
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithUnsignedInteger:previousIndex]];

    // Load new
    annotations = [documentAnnotations objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    annotationView.penPaths    = [annotations objectForKey:kPenPathsKey]; 
    annotationView.markerPaths = [annotations objectForKey:kMarkerPathsKey]; 
    previousIndex = index;
    
    return annotationView;
}

#pragma mark - UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webContentView.hidden = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(delay) withObject:nil afterDelay:0.5];
}

- (void)delay
{
    [self.delegate contentViewDidFinishLoad];
    webContentView.hidden = NO;
}

@end
