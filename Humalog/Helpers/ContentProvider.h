//
//  ContentProvider.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentDisplayDelegate.h"
#import "ContentControlProtocol.h"

#define kMarkerPathsKey @"markers"
#define kPenPathsKey    @"pens"

@interface ContentProvider : NSObject<UIWebViewDelegate> {
    id<ContentDisplayDelegate> delegate;
}
@property (nonatomic, retain) id<ContentDisplayDelegate> delegate;

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(int)index;
- (NSDictionary *)annotationsForDocumentAtIndex:(int)index;
- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(int)index;
- (int)count;
- (int)first;

@end
