//
//  StoreCategoriesViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/27/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "CategoriesViewController.h"
#import "SpiritListViewController.h"

#import "LiquorLocatorAppDelegate.h"
#import "Constants.h"
#import "FlurryAPI.h"

@implementation CategoriesViewController

@synthesize storeName;
@synthesize storeId;

@synthesize table;

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
    if (storeName != nil) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:storeName, @"Store", nil]; 
        [FlurryAPI logEvent:@"CategoriesView" withParameters:params];
    } else {
        [FlurryAPI logEvent:@"CategoriesView"];        
    }
#endif
 
    if (storeName != nil) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d/categories", storeId];
        self.feedURLString = query;
        self.title = storeName;
    } else {
        self.feedURLString = @"http://wsll.pugdogdev.com/categories";
        self.title = @"Categories";        
    }

    [super viewDidAppear:animated];
}

- (void)dealloc {
    [storeName release];
    [table release];
    
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
    
    if (storeName != nil) {
        spiritListController.storeId = storeId;
        spiritListController.storeName = storeName;
    }
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:spiritListController animated:YES];
    
    [spiritListController release];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CategoryTableIdentifier = @"CategoryTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CategoryTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CategoryTableIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *cat = [objectList objectAtIndex:row];
    cell.textLabel.text = [cat objectForKey:kCategory];
    cell.detailTextLabel.text = [cat objectForKey:kCount];
    
    return cell;
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}
@end
