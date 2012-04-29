//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "SlideProvider.h"
#import "WebContentView.h"


@interface SlideProvider() {
    NSMutableDictionary *documentAnnotations;
    NSArray             *documentTitles;
    NSArray             *categoriesAndIndices;
    WebContentView      *webContentView;
    NSString            *brandName;
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
        
        documentAnnotations = [NSMutableDictionary dictionary];
        

        NSArray *categories = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"]];
       NSArray *slides = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"slides_preference"]];
        
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i=0; i<[categories count]; i++) {
            NSRange match;
            NSString *cadena = [categories objectAtIndex:i];
            
            match = [cadena rangeOfString:@","];
            NSString *string1 = [cadena substringToIndex:match.location];
            NSString *string2 = [cadena substringFromIndex:match.location+1];
            
            [temp addObject:[NSValue valueWithRange:NSMakeRange([string1 intValue], [string2 intValue])]];
        }
        categoriesAndIndices = temp;
        documentTitles = slides;
                
            }

    return self;
}


- (NSUInteger)numberOfDocuments
{
    NSLog(@"slides:%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"slides_preference"]count]);
    NSLog(@"categorias:%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"]count]);    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"slides_preference"]count];
}

- (NSUInteger)numberOfCategories
{
    NSLog(@"categorias:%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"]count]);
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"]count];
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
    NSMutableString *path=[NSMutableString string];
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

- (UIView<ContentControlProtocol> *)viewForPDF:(NSString *)pdf
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"slides/"];    
    //UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 200, 200)];
    NSString *path = [newDir stringByAppendingPathComponent:pdf];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    return webContentView;
}


- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"resources/backs/"];
    NSString *brand = [[NSUserDefaults standardUserDefaults] stringForKey:@"brand"];
    brand = [brand lowercaseString];
    brand = [brand stringByAppendingString:@"_"];
    NSString *fileName = [[brand stringByAppendingString:[NSNumber numberWithUnsignedInt:index + 1].stringValue] stringByAppendingString:@".jpg"];
    //return [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];

    return [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:fileName]]];
}

- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index
{
    return [documentAnnotations objectForKey:[NSNumber numberWithUnsignedInt:index]];
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index
{
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithUnsignedInteger:index]];
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

// Delegation
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self.delegate contentViewDidFinishLoad];
//}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webContentView.hidden=YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(delay) withObject:nil afterDelay:.5];
    
    
}

- (void)delay{
    
    [self.delegate contentViewDidFinishLoad];
    webContentView.hidden=NO;
}

@end
