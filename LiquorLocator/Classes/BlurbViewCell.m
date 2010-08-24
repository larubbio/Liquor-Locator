//
//  BlurbViewCell.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "BlurbViewCell.h"

@implementation BlurbViewCell

@synthesize webView;

- (void)dealloc {
    [webView release];
    [super dealloc];
}

@end
