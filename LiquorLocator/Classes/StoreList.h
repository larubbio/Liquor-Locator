//
//  StoreList.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/7/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JSONLoaderController.h"

@interface StoreList : JSONLoaderController  <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *table;   
    IBOutlet MKMapView *map;
    
    NSArray *tableData;
}

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) NSArray *tableData;

- (void)toggleView:(id)sender;

@end
