//
//  StoreCategoriesViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/27/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@interface CategoriesViewController : JSONLoaderController <UITableViewDataSource, UITableViewDelegate> {
    NSString *storeName;
    int storeId;
    
    IBOutlet UITableView *table;
}

@property (nonatomic, retain) NSString *storeName;
@property (nonatomic, assign) int storeId;

@property (nonatomic, retain) UITableView *table;

@end
