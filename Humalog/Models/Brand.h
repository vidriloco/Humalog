//
//  Brand.h
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Brand : NSObject
{
    //Interface elements
//    NSString *brandName;
//    NSURL *brandURL; //Store logos, and brand related resources
//    NSURL *backImagesURL;
//    NSURL *navButtonsURL;
//    NSURL *menuButtonsURL;    
//    NSURL *overButtonsURL;
    
    //Structure elements
//    NSMutableDictionary *categories;
//    NSMutableDictionary *slidesByCategory;
//    NSMutableArray *slide;
    
    //PDF URL

}

@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSURL *brandURL;
@property (nonatomic, assign) BOOL isUpdated;
@property (nonatomic, assign) BOOL hasOpening;    
@property (nonatomic, assign) BOOL hasClosing;
@property (nonatomic, assign) BOOL hasIPP;
@property (nonatomic, assign) BOOL hasStudies;
@property (nonatomic, assign) BOOL hasSpecial;
@property (nonatomic, assign) BOOL hasReferences;
@property (nonatomic, assign) BOOL usesStackView;
@property (nonatomic, assign) int numberOfMenus;
@property (nonatomic, assign) int numberOfCategories;
@property (nonatomic, assign) int numberOfIpps;
@property (nonatomic, assign) int numberOfReferences;
@property (nonatomic, assign) int numberOfStudies;
@property (nonatomic, strong) NSArray *interfaceURL;
@property (nonatomic, strong) NSString *editURL;
@property (nonatomic, strong) NSArray *pdfs;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *slides;



@end
