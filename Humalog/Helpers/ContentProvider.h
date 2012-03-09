//
//  ContentProvider.h
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentControlProtocol.h"

@interface ContentProvider : NSObject {

}

- (UIView<ContentControlProtocol> *)viewForItemAtIndex:(int)index;
- (int)count;
- (int)first;

@end
