//
//  SpiritListViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpiritList.h"

@interface SpiritListViewController : SpiritList {
    
    NSString *category;
    NSString *brandName;
    int storeId;
    NSString *storeName;
}

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *brandName;
@property (nonatomic, assign) int storeId;
@property (nonatomic, retain) NSString *storeName;
@end
