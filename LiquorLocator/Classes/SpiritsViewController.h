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
    <UITableViewDelegate, UITableViewDataSource> {

    IBOutlet UISearchBar *search;
}

@property (nonatomic, retain) UISearchBar *search;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
@end
