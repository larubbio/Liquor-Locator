//
//  Category.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "Category.h"

@implementation Category

@synthesize name;

- (void)dealloc {
    [name release];
    [super dealloc];
}

@end
