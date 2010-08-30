//
//  SpiritListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritListViewController.h"
#import "SpiritDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"
#import "SpiritListViewController.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation SpiritListViewController

@synthesize category;
@synthesize brandName;
@synthesize storeId;
@synthesize storeName;

- (void)viewDidAppear:(BOOL)animated {
    indexed = YES;
    
    if (self.category != nil && self.storeId != 0) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d/spirits?category=%@", storeId, [Constants urlencode:category]];
        self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.title = category;        
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:storeName, @"Store", category, @"Category", nil]; 
        [FlurryAPI logEvent:@"StoreInventoryView" withParameters:params];

    } else if (self.category != nil) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirits?category=%@", [Constants urlencode:category]];
        self.feedURLString = query;
        self.title = category;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:category, @"Category", nil]; 
        [FlurryAPI logEvent:@"SpiritsView" withParameters:params];
        
    } else if (self.brandName != nil) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirits?name=%@", [Constants urlencode:brandName]];
        self.feedURLString = query;
        self.title = brandName;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:brandName, @"Name", nil]; 
        [FlurryAPI logEvent:@"SpiritsView" withParameters:params];
        
    } else if (self.storeId != 0) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d/spirits", storeId];
        self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.title = storeName;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:storeName, @"Store", nil]; 
        [FlurryAPI logEvent:@"StoreInventoryView" withParameters:params];
        
    } else {
        NSLog(@"No useful variable set in SpiritListViewController.  Don't know what to load");
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [category release];
    [brandName release];
    [super dealloc];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}


@end

