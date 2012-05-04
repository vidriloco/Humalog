//
//  Brand.m
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import "Brand.h"

@implementation Brand
@synthesize brandName, brandURL;
@synthesize isUpdated, hasOpening,hasClosing, hasIPP, hasStudies, hasSpecial, hasReferences,usesStackView;
@synthesize numberOfMenus, numberOfCategories,numberOfIpps, numberOfReferences, numberOfStudies;
@synthesize editURL,interfaceURL,pdfs,categories,slides;
@synthesize studies, IPPs, references;

+ (Brand *)sharedInstance
{
    static Brand *sharedInstance = nil;
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[Brand alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) {
        // Custom initialization
        brandName    = [NSString string];
        editURL      = [NSString string];
        brandURL     = [[NSURL alloc] init];
        interfaceURL = [NSArray array];        
        pdfs         = [NSArray array];                
        categories   = [NSArray array];
        slides       = [NSArray array];
        studies      = [NSArray array];
        IPPs         = [NSArray array];
        references   = [NSArray array];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (void)updateElementsFromDefaults
{
    Brand *configurator = [self sharedInstance];
    
    configurator.brandName          = [[NSUserDefaults standardUserDefaults] objectForKey:@"brand"];
    configurator.brandURL           = nil;
    configurator.categories         = [[NSUserDefaults standardUserDefaults] objectForKey:@"categories_preference"];
    configurator.slides             = [[NSUserDefaults standardUserDefaults] objectForKey:@"slides_preference"];
    configurator.hasOpening         = [[[NSUserDefaults standardUserDefaults] objectForKey:@"2"] boolValue];
    configurator.hasClosing         = [[[NSUserDefaults standardUserDefaults] objectForKey:@"1"] boolValue];
    configurator.hasIPP             = [[[NSUserDefaults standardUserDefaults] objectForKey:@"3"] boolValue];
    configurator.hasReferences      = [[[NSUserDefaults standardUserDefaults] objectForKey:@"4"] boolValue];
    configurator.hasSpecial         = [[[NSUserDefaults standardUserDefaults] objectForKey:@"5"] boolValue];
    configurator.hasStudies         = [[[NSUserDefaults standardUserDefaults] objectForKey:@"6"] boolValue];
    configurator.usesStackView      = [[[NSUserDefaults standardUserDefaults] objectForKey:@"7"] boolValue];
    configurator.isUpdated          = [[[NSUserDefaults standardUserDefaults] objectForKey:@"8"] boolValue];
    configurator.numberOfMenus      = [[[NSUserDefaults standardUserDefaults] objectForKey:@"menus"] intValue];
    configurator.numberOfCategories = configurator.categories.count;
    configurator.numberOfIpps       = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IPP"] count];
    configurator.numberOfReferences = [[[NSUserDefaults standardUserDefaults] objectForKey:@"REF"] count];
    configurator.numberOfStudies    = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EST"] count];
    configurator.interfaceURL       = nil;
    configurator.pdfs               = nil; // Superseded by the collections below
    configurator.editURL            = nil;
    
    // New collections in the singleton for quick document retrieval
    configurator.studies            = [[NSUserDefaults standardUserDefaults] objectForKey:@"EST"];
    configurator.references         = [[NSUserDefaults standardUserDefaults] objectForKey:@"REF"];
    configurator.IPPs               = [[NSUserDefaults standardUserDefaults] objectForKey:@"IPP"];
}

@end
