//
//  StoreCategoriesViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/27/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesList.h"

@interface StoreCategoriesViewController : CategoriesList {
    NSString *storeName;
    int storeId;
}

@property (nonatomic, retain) NSString *storeName;
@property (nonatomic, assign) int storeId;
@end
