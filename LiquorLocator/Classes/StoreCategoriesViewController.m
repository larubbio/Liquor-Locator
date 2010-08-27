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

@implementation StoreCategoriesViewController

@synthesize storeName;
@synthesize storeId;

- (void)viewDidAppear:(BOOL)animated {
    NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d/categories", storeId];
    self.feedURLString = query;
    self.title = storeName;

    [super viewDidAppear:animated];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    SpiritListViewController *spiritListController = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];
    spiritListController.category = [objectList objectAtIndex:row];
    spiritListController.storeId = storeId;
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:spiritListController animated:YES];
    
    [spiritListController release];    
}


@end
