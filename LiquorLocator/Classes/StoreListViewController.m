//
//  StoreListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreListViewController.h"

@implementation StoreListViewController

@synthesize spiritId;

- (void)viewDidAppear:(BOOL)animated {
    NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirit/%@/stores", spiritId];
    self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [spiritId release];
    [super dealloc];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}

@end
