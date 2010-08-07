//
//  SpiritsViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritsViewController.h"

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
        NSString *name = [spirit objectForKey:@"n"];
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
    [allSpirits release];
    [search release];
    [super dealloc];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];

    [allSpirits release];
    allSpirits = [[NSMutableArray alloc] initWithArray:self.objectList copyItems:YES];
    
    [table reloadData];
}

@end
