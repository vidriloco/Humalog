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
#import "DocumentDataSource.h"
#import "AnnotationDataSource.h"

#define kMarkerPathsKey @"markers"
#define kPenPathsKey    @"pens"

@interface SlideProvider : NSObject<UIWebViewDelegate, DocumentDataSource, AnnotationDataSource> {
    id<ContentDisplayDelegate> delegate;
}
@property (nonatomic, retain) id<ContentDisplayDelegate> delegate;


@end
