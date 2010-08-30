//
//  SearchViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SearchViewController.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation SearchViewController

@synthesize search;

- (void)viewDidAppear {
    search.autocapitalizationType = UITextAutocapitalizationTypeNone;
    search.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewDidAppear:(BOOL)animated {
    indexed = NO;
    
    [table reloadData];
}

- (void)dealloc {
    [search release];
    [super dealloc];
}

- (void)resetSearch {
    if (spirits != nil) {
        [spirits release];
        spirits = nil;
    }
    spirits = [[NSMutableDictionary alloc] init];
    
    if (keys != nil) {
        [keys release];
        keys = nil;
    }
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:searchTerm, @"SearchTerm", nil]; 
    [FlurryAPI logEvent:@"Search" withParameters:params];

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
    if (self.JSONConnection != nil) {
        [self.JSONConnection cancel];
        self.JSONConnection = nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirits?search=%@", [Constants urlencode:searchTerm]];
    self.feedURLString = query;

    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Todo: Add cache.  Calling this twice and then scrolling before the list is reloaded causes a crash
    // since it attempts to get a cell yet I empty out the object list.
    self.objectList = [NSMutableArray array];
    
//    NSLog(@"Connecting to %@", self.feedURLString);
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.JSONConnection = [[[NSURLConnection alloc] initWithRequest:URLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.JSONConnection != nil, @"Failure to create URL connection.");
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([search isFirstResponder]) {
        [self searchBarSearchButtonClicked:search];
    }

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [self resetSearch];
    
    // Loop over objects
    for (NSMutableDictionary *spirit in objects) {
        NSString *firstLetter = [[spirit objectForKey:kShortName] substringToIndex:1];
        
        if ([self.spirits objectForKey:firstLetter]) {
            NSMutableArray *list = [self.spirits objectForKey:firstLetter];
            [list addObject:spirit];
        } else {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject:spirit];
            [self.spirits setObject:list forKey:firstLetter];
            
            [list release];
        }
    }
    
    NSArray *array = [[spirits allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.keys = array;
    
    [table reloadData];
}
    
@end
