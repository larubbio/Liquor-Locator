//
//  DistillerAddressCell.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DistillerAddressCell : UITableViewCell {
    IBOutlet MKMapView *map;
    IBOutlet UILabel *street;
    IBOutlet UILabel *address;
    IBOutlet UILabel *phone;
}

@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) UILabel *street;
@property (nonatomic, retain) UILabel *address;
@property (nonatomic, retain) UILabel *phone;

@end
