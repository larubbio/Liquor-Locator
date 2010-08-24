//
//  DistillerAddressCell.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "DistillerAddressCell.h"

@implementation DistillerAddressCell

@synthesize map;
@synthesize street;
@synthesize address;
@synthesize phone;

- (void)dealloc {
    [map release];
    [street release];
    [address release];
    [phone release];
    [super dealloc];
}

@end
