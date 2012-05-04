//
//  SplashscreenViewController.m
//  Humalog
//
//  Created by Workstation on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashscreenViewController.h"
#import "Viewport.h"

@interface SplashscreenViewController ()

@end

@implementation SplashscreenViewController
@synthesize progress;

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[Viewport screenArea]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash.png"]];

    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    [progress setFrame:CGRectMake(self.view.frame.size.width/2.5, self.view.frame.size.height/1.5, 200.0, 10.0)];
    [self.view addSubview:progress];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
