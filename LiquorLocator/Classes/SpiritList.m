//
//  SpiritList.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/7/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritList.h"
#import "SpiritListViewController.h"
#import "SpiritDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

@implementation SpiritList

@synthesize table;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [table release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SingleSpiritCellIdentifier = @"SingleSpiritCellIdentifier";
    static NSString *MultiSpiritCellIdentifier = @"MultiSpiritCellIdentifier";
    
    UITableViewCell *cell;
    
    NSUInteger row = [indexPath row];
    NSDictionary *spirit = [objectList objectAtIndex:row]; 

    if ([spirit objectForKey:@"id"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:SingleSpiritCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SingleSpiritCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        NSString *detail = [NSString stringWithFormat:@"Size: %@ Price: $%@", [spirit objectForKey:@"s"], [spirit objectForKey:@"p"]];
        cell.detailTextLabel.text = detail;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:MultiSpiritCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MultiSpiritCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.detailTextLabel.text = [spirit objectForKey:@"c"];
    }

    cell.textLabel.text = [spirit objectForKey:@"n"];
    
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
        ((SpiritListViewController *)controller).brandName = [spirit objectForKey:@"n"];
    }
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

@end
