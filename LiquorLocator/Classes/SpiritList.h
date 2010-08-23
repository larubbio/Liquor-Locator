//
//  SpiritList.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/7/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"


@interface SpiritList : JSONLoaderController  <UITableViewDataSource, UITableViewDelegate>  {
    IBOutlet UITableView *table;   
    
    NSMutableDictionary *spirits;
    NSArray *keys;
    
    BOOL indexed;
}

@property (nonatomic, retain) UITableView *table;

@property (nonatomic, retain) NSMutableDictionary *spirits;
@property (nonatomic, retain) NSArray *keys;

@property (nonatomic, assign) BOOL indexed;
@end
