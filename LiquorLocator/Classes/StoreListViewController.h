//
//  StoreListViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreList.h"

@interface StoreListViewController : StoreList {
    NSString *spiritId;
    NSString *spiritName;
}

@property (nonatomic, retain) NSString *spiritId;
@property (nonatomic, retain) NSString *spiritName;
@end
