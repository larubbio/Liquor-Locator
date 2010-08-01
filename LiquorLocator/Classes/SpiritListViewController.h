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
    
    // Store
}

@property (nonatomic, retain) NSString *category;

- (void)setCategory:(NSString *)category;

@end
