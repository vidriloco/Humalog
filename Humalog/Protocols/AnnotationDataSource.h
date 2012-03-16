//
//  AnnotationDataSource.h
//  Humalog
//
//  Created by Workstation on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnotationDataSource <NSObject>
- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index;
- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index;
@end
