//
//  DistillerDetailViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/23/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@class DistillerAddressCell;

@interface DistillerDetailViewController : JSONLoaderController <UITableViewDelegate, UITableViewDataSource> {
    int distillerId;

    IBOutlet UITableView *table;
    
    IBOutlet DistillerAddressCell *addressCell;
}

@property (nonatomic, assign) int distillerId;

@property (nonatomic, retain) UITableView *table;

@property (nonatomic, retain) DistillerAddressCell *addressCell;
@end
