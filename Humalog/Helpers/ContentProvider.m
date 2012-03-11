//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "ContentProvider.h"
#import "WebContentView.h"

@interface ContentProvider() {
    NSMutableDictionary *documentAnnotations;
}

@end

@implementation ContentProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        [[WebContentView sharedInstance] setDelegate:self];
        documentAnnotations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (int)first
{
    return 1;
}

- (int)count
{
    return 13;
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(int)index
{
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithInt:index] stringValue]];
    NSString *path = [[NSBundle mainBundle] pathForResource:slideName ofType:@"html" inDirectory:[@"slides/" stringByAppendingString:slideName]];
    
    [[WebContentView sharedInstance] setScalesPageToFit:NO];
    [[WebContentView sharedInstance] scrollView].scrollEnabled = NO;
    
    if (index == [self count]) {
        path = [[NSBundle mainBundle] pathForResource:@"plato" ofType:@"pdf"];
        [[WebContentView sharedInstance] setScalesPageToFit:YES];
        [[WebContentView sharedInstance] scrollView].scrollEnabled = YES;
    }
    
    if (!path)
        return nil;
    
    NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                        relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                  isDirectory: YES]];
    
    [[WebContentView sharedInstance] loadRequest:[NSURLRequest requestWithURL:url]];
    return [WebContentView sharedInstance];
}

- (NSDictionary *)annotationsForDocumentAtIndex:(int)index
{
    return [documentAnnotations objectForKey:[NSNumber numberWithInt:index]];
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(int)index
{
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithInt:index]];
}

// Delegation

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate performSelector:@selector(contentViewDidFinishLoad) withObject:nil];
}

@end
