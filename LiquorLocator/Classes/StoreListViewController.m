//
//  StoreListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreListViewController.h"
#import "StoreDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

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
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StoreTableIdentifier = @"StoreTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StoreTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StoreTableIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *storeInv = [objectList objectAtIndex:row]; 
    NSDictionary *store = [storeInv objectForKey:@"store"];
    cell.textLabel.text = [store objectForKey:@"name"];
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSDictionary *storeInv = [objectList objectAtIndex:row]; 
    NSDictionary *store = [storeInv objectForKey:@"store"];
    
    StoreDetailViewController *storeDetailViewController = [[StoreDetailViewController alloc] initWithNibName:@"StoreDetailView" bundle:nil];
    storeDetailViewController.storeId = [((NSString *)[store objectForKey:@"id"]) intValue];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:storeDetailViewController animated:YES];
    
    [storeDetailViewController release];
}

@end
