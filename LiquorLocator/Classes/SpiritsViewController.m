//
//  SpiritsViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritsViewController.h"
#import "SpiritListViewController.h"
#import "SpiritDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

@implementation SpiritsViewController

@synthesize search;
@synthesize allSpirits;

- (void)resetSearch {
    [objectList release];
    objectList = [[NSMutableArray alloc] initWithArray:self.allSpirits copyItems:YES];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [table reloadData];
        return;
    }
    
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    search.text = @"";
    [self resetSearch];
    [table reloadData];
    [searchBar resignFirstResponder];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    [self resetSearch];
    
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (NSDictionary *spirit in self.objectList) {
        NSString *name = [spirit objectForKey:@"brand_name"];
        if([name rangeOfString:searchTerm
                       options:NSCaseInsensitiveSearch].location == NSNotFound) {
            [toRemove addObject:spirit];
        }
    }
    
    [self.objectList removeObjectsInArray:toRemove];
    [table reloadData];
    [toRemove release];
}
    
- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = @"http://wsll.pugdogdev.com/spirits";
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
    [allSpirits release];
    [search release];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SpiritTableIdentifier = @"SpiritTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SpiritTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SpiritTableIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *spirit = [objectList objectAtIndex:row]; 
    cell.textLabel.text = [spirit objectForKey:@"brand_name"];
        
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id controller;
    NSUInteger row = [indexPath row];
    NSDictionary *spirit = [objectList objectAtIndex:row]; 
    
    if ([spirit objectForKey:@"id"]) {
        controller = [[SpiritDetailViewController alloc] initWithNibName:@"SpiritDetailView" bundle:nil];
        ((SpiritDetailViewController *)controller).spiritId = [spirit objectForKey:@"id"];
    } else {
        controller = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];   
        ((SpiritListViewController *)controller).brandName = [spirit objectForKey:@"brand_name"];
    }
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    [allSpirits release];
    allSpirits = [[NSMutableArray alloc] initWithArray:self.objectList copyItems:YES];
}
@end
