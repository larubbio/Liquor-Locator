//
//  StoresViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoresViewController.h"
#import "FlurryAPI.h"

@implementation StoresViewController

- (void)viewDidAppear:(BOOL)animated {
#ifdef FLURRY
    [FlurryAPI logEvent:@"StoresView"];
#endif
    
    self.feedURLString = @"http://wsll.pugdogdev.com/stores";
    
    [super viewDidAppear:animated];    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}

@end
