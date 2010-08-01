//
//  SpiritsViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@interface SpiritsViewController : JSONLoaderController 
    <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {

    NSArray *allSpirits;
    IBOutlet UISearchBar *search;
}

@property (nonatomic, retain) NSArray *allSpirits;
@property (nonatomic, retain) UISearchBar *search;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
@end
