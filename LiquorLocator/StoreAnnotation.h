//
//  StoreAnnotation.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StoreAnnotation : NSObject <MKAnnotation> {
    UIImage *image;
    
    NSString *name;
    NSString *address;
    
    double latitude;
    double longitude;
}

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
