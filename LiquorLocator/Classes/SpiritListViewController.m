//
//  SpiritListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritListViewController.h"


@implementation SpiritListViewController

@synthesize category;
@synthesize brandName;

- (void)viewDidAppear:(BOOL)animated {
    if (self.category != nil) {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirits?category=%@", category];
        self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirits?name=%@", brandName];
        self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [category release];
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

@end

