//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentProvider.h"
#import "WebContentView.h"

@implementation ContentProvider

- (id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (int)first {
    return 2;
}

- (int)count {
    return 11;
}

- (UIView<ContentControlProtocol> *)viewForItemAtIndex:(int)index
{
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithInt:index] stringValue]];
    NSString *path = [[NSBundle mainBundle] pathForResource:slideName ofType:@"html" inDirectory:[@"slides/" stringByAppendingString:slideName]];
    if (path) {
        NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                            relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                      isDirectory: YES]];
        
        [[WebContentView sharedInstance] loadRequest:[NSURLRequest requestWithURL:url]];
        return [WebContentView sharedInstance];
    }
    return nil;
}

@end
