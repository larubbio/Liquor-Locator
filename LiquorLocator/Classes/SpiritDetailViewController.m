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

#import "Constants.h"
#import "FlurryAPI.h"

@implementation SpiritDetailViewController

@synthesize spiritId;

@synthesize spiritName;
@synthesize onSale;
@synthesize priceBtn;
@synthesize sizeBtn;
@synthesize viewStoresBtn;

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
    [spiritName release];
    [onSale release];
    [priceBtn release];
    [sizeBtn release];
    [viewStoresBtn release];
    [super dealloc];
}

- (void)viewStores:(id)sender {
    StoreListViewController *controller = [[StoreListViewController alloc] initWithNibName:@"StoreListView" bundle:nil];   
    ((StoreListViewController *)controller).spiritId = spiritId;
    ((StoreListViewController *)controller).spiritName = [self.objectList objectForKey:kBrandName];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
#ifdef FLURRY
    NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:[self.objectList objectForKey:kBrandName], @"Spirit", nil]; 
    [FlurryAPI logEvent:@"SpiritDetail" withParameters:searchParameters];
#endif
    
    NSString *priceTitle = [NSString stringWithFormat:@"Cost: $%@", [objectList objectForKey:kPrice]];
    NSString *sizeTitle = [NSString stringWithFormat:@"Size: %@ Liters", [objectList objectForKey:kSize]];
    
    spiritName.text = [objectList objectForKey:kBrandName];
    spiritName.hidden = NO;
    
    BOOL on_sale = [((NSString *)[objectList objectForKey:kOnSale]) boolValue];
    BOOL closeout = [((NSString *)[objectList objectForKey:kCloseout]) boolValue];
    
    if (on_sale && closeout) {
        onSale.text = @"This product is on sale and closeout.";
        onSale.hidden = NO;
    } else if (on_sale) {
        onSale.text = @"This product is on sale.";
        onSale.hidden = NO;
    } else if (closeout) {
        onSale.text = @"This product is on closeout.";
        onSale.hidden = NO;
    }    
    [priceBtn setTitle:priceTitle forState:UIControlStateNormal];
    priceBtn.hidden = NO;
    [sizeBtn setTitle:sizeTitle forState:UIControlStateNormal];
    sizeBtn.hidden = NO;
    
    viewStoresBtn.hidden = NO;
    
    self.title = [objectList objectForKey:kBrandName];
}

@end
