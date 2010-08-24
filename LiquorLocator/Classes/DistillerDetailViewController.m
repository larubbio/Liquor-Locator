//
//  DistillerDetailViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/23/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "DistillerDetailViewController.h"


@implementation DistillerDetailViewController

@synthesize table;

- (void)dealloc {
    [table release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 1;
    } else {
        NSArray *list = [self.objectList objectForKey:@"spirits"];
        
        return [list count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.objectList != nil) {
            return [self.objectList objectForKey:@"name"];
        } else {
            return nil;
        }
    } else if (section == 1) {
        return @"URL";
    } else if (section == 2) {
        return @"Spirits";
    }
    
    return nil;
}

#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define PHOTO_TAG 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // For section 0 I need the custom cell with map and address
    
    // For section 1 a simple cell with text
    
    // For section 2 I need the spirit cell
/*
    static NSString *CellIdentifier = @"ImageOnRightCell";
    
    UILabel *mainLabel, *secondLabel;
    UIImageView *photo;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, 15.0)] autorelease];
        mainLabel.tag = MAINLABEL_TAG;
        mainLabel.font = [UIFont systemFontOfSize:14.0];
        mainLabel.textAlignment = UITextAlignmentRight;
        mainLabel.textColor = [UIColor blackColor];
        mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:mainLabel];
        
        secondLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 220.0, 25.0)] autorelease];
        secondLabel.tag = SECONDLABEL_TAG;
        secondLabel.font = [UIFont systemFontOfSize:12.0];
        secondLabel.textAlignment = UITextAlignmentRight;
        secondLabel.textColor = [UIColor darkGrayColor];
        secondLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:secondLabel];
        
        photo = [[[UIImageView alloc] initWithFrame:CGRectMake(225.0, 0.0, 80.0, 45.0)] autorelease];
        photo.tag = PHOTO_TAG;
        photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:photo];
    } else {
        mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        secondLabel = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
        photo = (UIImageView *)[cell.contentView viewWithTag:PHOTO_TAG];
    }
    NSDictionary *aDict = [self.list objectAtIndex:indexPath.row];
    mainLabel.text = [aDict objectForKey:@"mainTitleKey"];
    secondLabel.text = [aDict objectForKey:@"secondaryTitleKey"];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[aDict objectForKey:@"imageKey"] ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    photo.image = theImage;
    
    return cell;
*/
    return nil;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // For section 0 load map?  Call number?
    
    // For section 1 open url in safari
    
    // For section 2 go to spirit detail page.
    
    /*
     DistillerDetailViewController *controller;
     
     NSUInteger section = [indexPath section];
     if (section != 1) {
     return nil;
     }
     
     NSUInteger row = [indexPath row];
     
     NSArray *distillerSection = [self.distillers objectForKey:[NSNumber numberWithInt:row]];
     NSDictionary *distiller = [distillerSection objectAtIndex:row]; 
     
     controller = [[DistillerDetailViewController alloc] initWithNibName:@"DistillerDetailView" bundle:nil];
     
     LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
     [delegate.navController pushViewController:controller animated:YES];
     
     [controller release];
     */
}

@end
