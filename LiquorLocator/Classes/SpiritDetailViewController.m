//
//  SpiritDetailViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritDetailViewController.h"
#import "StoreListViewController.h"
#import "LiquorLocatorAppDelegate.h"

@implementation SpiritDetailViewController

@synthesize spiritId;

@synthesize priceBtn;
@synthesize sizeBtn;
@synthesize viewStoresBtn;

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"View will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirit/%@", spiritId];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [spiritId release];
    [priceBtn release];
    [sizeBtn release];
    [viewStoresBtn release];
    [super dealloc];
}

- (void)viewStores:(id)sender {
    StoreListViewController *controller = [[StoreListViewController alloc] initWithNibName:@"StoreListView" bundle:nil];   
    ((StoreListViewController *)controller).spiritId = spiritId;
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    NSString *priceTitle = [NSString stringWithFormat:@"Cost: $%@", [objectList objectForKey:@"price"]];
    NSString *sizeTitle = [NSString stringWithFormat:@"Size: %@ Liters", [objectList objectForKey:@"size"]];
    
    [priceBtn setTitle:priceTitle forState:UIControlStateNormal];
    priceBtn.hidden = NO;
    [sizeBtn setTitle:sizeTitle forState:UIControlStateNormal];
    sizeBtn.hidden = NO;
    
    viewStoresBtn.hidden = NO;
    
    self.title = [objectList objectForKey:@"brand_name"];
}

@end
