//
//  SpiritListViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@interface SpiritListViewController : JSONLoaderController <UITableViewDelegate, UITableViewDataSource> {
    
    NSString *category;
    NSString *brandName;
    int storeId;
    
    // Store
}

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *brandName;
@property (nonatomic, assign) int storeId;

@end
