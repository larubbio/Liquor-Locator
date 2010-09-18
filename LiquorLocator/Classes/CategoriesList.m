    //
//  CategoriesList.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/27/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "CategoriesList.h"
#import "Constants.h"

@implementation CategoriesList

@synthesize table;

- (void)dealloc {
    [table release];
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
