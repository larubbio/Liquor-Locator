//
//  StoreCategoriesViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/27/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreCategoriesViewController.h"
#import "SpiritListViewController.h"

#import "LiquorLocatorAppDelegate.h"
#import "Constants.h"
#import "FlurryAPI.h"

@implementation StoreCategoriesViewController

@synthesize storeName;
@synthesize storeId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAdBannerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fixupAdView:[UIDevice currentDevice].orientation];
}

- (void)viewDidAppear:(BOOL)animated {
#ifdef FLURRY
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:storeName, @"Store", nil]; 
    [FlurryAPI logEvent:@"CategoriesView" withParameters:params];
#endif
    
    NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d/categories", storeId];
    self.feedURLString = query;
    self.title = storeName;

    [super viewDidAppear:animated];
}

- (void)dealloc {
    [storeName release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSDictionary *cat = [objectList objectAtIndex:row];
    
    SpiritListViewController *spiritListController = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];
    spiritListController.category = [cat objectForKey:kCategory];
    spiritListController.storeId = storeId;
    spiritListController.storeName = storeName;
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:spiritListController animated:YES];
    
    [spiritListController release];    
}

@end
