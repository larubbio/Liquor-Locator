//
//  StoreAnnotation.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreAnnotation.h"


@implementation StoreAnnotation

@synthesize image;

@synthesize name;
@synthesize address;
@synthesize storeId;

@synthesize latitude;
@synthesize longitude;


- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = latitude;
    theCoordinate.longitude = longitude;
    
    return theCoordinate; 
}

- (void)dealloc
{
    [image release];
    [name release];
    [address release];
    
    [super dealloc];
}

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    return address;
}

@end
