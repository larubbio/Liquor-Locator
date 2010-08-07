//
//  StoresViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoresViewController.h"
#import "StoreDetailViewController.h"
#import "StoreAnnotation.h"
#import "LiquorLocatorAppDelegate.h"
#import "RootViewController.h"

@implementation StoresViewController

- (void)viewDidAppear:(BOOL)animated {
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

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}

@end
