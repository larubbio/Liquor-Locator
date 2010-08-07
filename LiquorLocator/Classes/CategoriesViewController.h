//
//  CategoriesViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@interface CategoriesViewController : JSONLoaderController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *table;
}

@property (nonatomic, retain) UITableView *table;
@end
