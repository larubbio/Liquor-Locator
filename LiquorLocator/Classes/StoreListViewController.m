//
//  StoreListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreListViewController.h"
#import "FlurryAPI.h"

@implementation StoreListViewController

@synthesize spiritId;
@synthesize spiritName;

- (void)viewDidAppear:(BOOL)animated {
#ifdef FLURRY
    NSDictionary *params= [NSDictionary dictionaryWithObjectsAndKeys:spiritName, @"Spirit", nil]; 
    [FlurryAPI logEvent:@"StoresView" withParameters:params];
#endif
    
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

@end
