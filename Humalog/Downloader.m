//
//  Downloader.m
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import "Downloader.h"
#import "Brand.h"

@interface Downloader(){
    Brand *configurator;
}
@end

@implementation Downloader

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        configurator = [[Brand alloc]init];
    }
    return self;
}


- (void) parseJSON:(NSString *)brand {
    
    NSString *file=[brand stringByAppendingString:@".json"];
    NSURL *url = [NSURL URLWithString:[kBrandURL stringByAppendingString:file]];

    dispatch_sync(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: 
                        url];
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];
    });
    dispatch_release(kBgQueue);
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData //1
                          options:kNilOptions 
                          error:&error];
    
    [self updateElementsWithJSON:json];
}

- (void) updateElementsWithJSON:(NSDictionary *)json{
    
    configurator.brandName = [[json objectForKey:@"brand"] valueForKey:@"name"];
    configurator.brandURL = [[json objectForKey:@"brand"] valueForKey:@"url"];

    //Get slides and urls to download

    configurator.categories = [json objectForKey:@"categories"];
    configurator.slides = [[json objectForKey:@"categories"] valueForKey:@"category"];
    
    //Assign configuration flags
    
    configurator.hasOpening = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_opening"] boolValue];
    configurator.hasClosing = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_closing"] boolValue];
    configurator.hasIPP = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_ipp"] boolValue];
    configurator.hasReferences = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_references"] boolValue];
    configurator.hasSpecial = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_special"] boolValue];
    configurator.hasStudies = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_studies"] boolValue];
    configurator.usesStackView = [[[json objectForKey:@"interface_configuration"] valueForKey:@"uses_stack_view"] boolValue];
    configurator.isUpdated = [[[json objectForKey:@"interface_configuration"] valueForKey:@"updated_device"] boolValue];    
    
    //get some statistics
    
    configurator.numberOfMenus = [[[json objectForKey:@"interface_configuration"] valueForKey:@"number_of_menus"] intValue];    
    configurator.numberOfCategories = [[json objectForKey:@"number_of_categories"]intValue];
    configurator.numberOfIpps = [[json objectForKey:@"number_of_ipps"]intValue];
    configurator.numberOfReferences = [[json objectForKey:@"number_of_references"]intValue];    
    configurator.numberOfStudies = [[json objectForKey:@"number_of_studies"]intValue];        

    
    //get interface urls to download
    configurator.interfaceURL = [json objectForKey:@"interface_urls"];
    
    //get pdf urls to download
    configurator.pdfs = [json objectForKey:@"pdfs"];
    
    NSLog(@"brand: %@", configurator.brandName);
    NSLog(@"brand: %@", configurator.brandURL);
    NSLog(@"number_of_slides: %@", [configurator.categories valueForKey:@"number_of_slides"]);
    
    NSLog(@"category_name: %@", [configurator.categories valueForKey:@"orden"]);
    NSLog(@"slides: %@", [[configurator.slides valueForKey:@"orden"]objectAtIndex:0]);
    NSLog(@"slides: %@", [configurator.slides valueForKey:@"url"]);
    NSLog(@"interface_Conf: %d", configurator.isUpdated);
    NSLog(@"interface_Conf: %d", configurator.usesStackView);    
    NSLog(@"interface_url: %@", configurator.interfaceURL);
    NSLog(@"Pdfs: %@", configurator.pdfs);
    NSLog(@"noCategories: %d", configurator.numberOfCategories);
    NSLog(@"%@",[configurator.interfaceURL valueForKey:@"backgrounds_url"]);

    //Download interface elements

    BOOL force = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_interface_preference"];
    BOOL force2 = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_slides_preference"];
    if(!configurator.isUpdated || force){
        

        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"resources"];
        NSError *error;	
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
            {
                NSLog(@"Delete directory error: %@", error);
            }
        }
        
        
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"backgrounds_url"] withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"btn_url"]withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"nav_btn_url"]withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"over_btn_url"]withDir:@"resources"];        
        [self updateServer:[json objectForKey:@"update_interface"]];

    }
    if(!configurator.isUpdated || force2) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"slides"];
        NSError *error;	
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
            {
                NSLog(@"Delete directory error: %@", error);
            }
        }
        for (int i=0; i<[[configurator.slides valueForKey:@"url"] count]; i++) {
            for (int j=0; j<[[[configurator.slides valueForKey:@"url"] objectAtIndex:i]count]; j++) {
                [self downloadWithStringURL:[[[configurator.slides valueForKey:@"url"] objectAtIndex:i]objectAtIndex:j] withDir:@"slides"];
           }
        }

    }
    
    
    
    
    
}




- (void) downloadWithStringURL:(NSString *)urlString withDir:(NSString *) dir{
    NSString *urlAsString = urlString;
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url]; 
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) 
    {
         if ([data length] >0 && error == nil)
         {
             /* Get the documents directory */
             NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                           NSUserDomainMask,
                                                                           YES) objectAtIndex:0];
             /* Append the file name to the documents directory */
             NSFileManager *filemgr =[NSFileManager defaultManager];

             NSString *newDir = [documentsDir stringByAppendingPathComponent:dir];
             if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
             {
                 NSLog(@"Failure in creating directory");
             }
             NSLog(@"%@",newDir);
             
             NSString *filePath = [newDir stringByAppendingPathComponent:[url lastPathComponent]];
             /* Write the data to the file */ 
             [data writeToFile:filePath atomically:YES];
             NSLog(@"Successfully saved the file to %@", filePath);
             [self unzip:filePath];  
         }
         else if ([data length] == 0 && error == nil)
         { 
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil)
         {
             NSLog(@"Error happened = %@", error); 
         }
     }];
}

- (void) updateServer:(NSString*)url{

    NSString *fix = [url stringByDeletingLastPathComponent];
        NSLog(@"url:%@",fix);
    NSURL *rURL = [NSURL URLWithString:fix];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rURL]; 
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSString *body = @"interface[updated_device=1&commit=Update Interface"; 
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *error) 
    {
                               
         if ([data length] >0 && error == nil)
         {
             NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"HTML = %@", html); 
         }
                               
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
                               
         }
                               
         else if (error != nil)
         {
                                   
             NSLog(@"Error happened = %@", error); 
         }
                               
    }];
    
}


- (void)unzip:(NSString *)filePath
{
    

//    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                  NSUserDomainMask,
//                                                                  YES) objectAtIndex:0];
    NSString *newDir = [filePath stringByDeletingLastPathComponent];
    NSFileManager *filemgr =[NSFileManager defaultManager];
    NSString *file = [filePath lastPathComponent];
    //NSString *downDir = [[NSBundle mainBundle]bundlePath];
    if ([filemgr fileExistsAtPath:[newDir stringByAppendingPathComponent:file]])
    {
        NSData *unzipData = [NSData dataWithContentsOfFile:file];
        [filemgr createFileAtPath:newDir contents:unzipData attributes:nil];
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:filePath])
        {
            if ([zipArchive UnzipFileTo:newDir overWrite:NO])
            {
                NSLog(@"Archive unzip success");
                [filemgr removeItemAtPath:filePath error:NULL];
            }
            else
            {
                NSLog(@"Failure to unzip archive");
            }
        }
        else
        {
            NSLog(@"Failure to open archive");
        }
        
    }   
}

-(NSArray *)brandCategories
{
    return configurator.categories;
}

-(NSArray *)brandSlides
{
    return configurator.slides;
}



@end
