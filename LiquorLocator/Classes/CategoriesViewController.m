//
//  CategoriesViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "CategoriesViewController.h"
#import "SpiritListViewController.h"

#import "LiquorLocatorAppDelegate.h"
#import "FlurryAPI.h"
#import "Constants.h"

@implementation CategoriesViewController

- (void)viewDidAppear:(BOOL)animated {
#ifdef FLURRY    
    [FlurryAPI logEvent:@"CategoriesView"];
#endif
    
    self.feedURLString = @"http://wsll.pugdogdev.com/categories";
    
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
    NSDictionary *cat = [objectList objectAtIndex:row];
    
    SpiritListViewController *spiritListController = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];
    spiritListController.category = [cat objectForKey:kCategory];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:spiritListController animated:YES];
    
    [spiritListController release];    
}

@end
