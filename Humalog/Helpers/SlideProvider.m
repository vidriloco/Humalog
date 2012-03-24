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
    NSDictionary        *categoriesAndIndices;
    WebContentView      *webContentView;
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
        webContentView.scrollView.scrollEnabled = NO;
        
        documentAnnotations = [NSMutableDictionary dictionary];
        
        categoriesAndIndices = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSArray arrayWithObjects:
                                 [NSNumber numberWithUnsignedInt:1],
                                 [NSNumber numberWithUnsignedInt:2],
                                 [NSNumber numberWithUnsignedInt:3],
                                 nil], @"Epidemiología",
                                
                                [NSArray arrayWithObjects:
                                 [NSNumber numberWithUnsignedInt:4],
                                 [NSNumber numberWithUnsignedInt:5],
                                 [NSNumber numberWithUnsignedInt:6],
                                 nil], @"Brilinta",
                                
                                [NSArray arrayWithObjects:
                                 [NSNumber numberWithUnsignedInt:7],
                                 [NSNumber numberWithUnsignedInt:8],
                                 [NSNumber numberWithUnsignedInt:9],
                                 nil], @"Eficacia",
                                
                                [NSArray arrayWithObjects:
                                 [NSNumber numberWithUnsignedInt:10],
                                 nil], @"Seguridad",
                                
                                [NSArray arrayWithObjects:
                                 [NSNumber numberWithUnsignedInt:11],
                                 [NSNumber numberWithUnsignedInt:12],
                                 nil], @"Posología",
                                nil];
    }
    return self;
}

- (NSUInteger)numberOfDocuments
{
    return 12;
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithUnsignedInt:index + 1] stringValue]];
    NSString *path = [[NSBundle mainBundle] pathForResource:slideName
                                                     ofType:@"html"
                                                inDirectory:[@"slides/" stringByAppendingString:slideName]];
    
    if (!path)
        return nil;
    
    NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                        relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                  isDirectory: YES]];
    
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    return webContentView;
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString *fileName = [[@"brilinta_" stringByAppendingString:[NSNumber numberWithUnsignedInt:index + 1].stringValue] stringByAppendingString:@".jpg"];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
}

- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index
{
    return [documentAnnotations objectForKey:[NSNumber numberWithUnsignedInt:index]];
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index
{
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithUnsignedInt:index]];
}

- (NSArray *)categoryNames
{
    return [categoriesAndIndices allKeys];
}

- (NSArray *)documentIndicesForCategoryNamed:(NSString *)categoryName
{
    return [categoriesAndIndices objectForKey:categoryName];
}

// Delegation
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate contentViewDidFinishLoad];
}

@end
