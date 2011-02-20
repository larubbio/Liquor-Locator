//
//  Constants.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/9/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Constants : NSObject {
}
// JSON constants
extern NSString *const kId;
extern NSString *const kName;
extern NSString *const kStore;
extern NSString *const kQty;
extern NSString *const kDist;
extern NSString *const kStreet;
extern NSString *const kAddress;
extern NSString *const kAddress2;
extern NSString *const kCity;
extern NSString *const kZip;
extern NSString *const kLat;
extern NSString *const kLong;
extern NSString *const kContacts;
extern NSString *const kRole;
extern NSString *const kNumber;
extern NSString *const kHours;
extern NSString *const kStartDay;
extern NSString *const kEndDay;
extern NSString *const kOpen;
extern NSString *const kClose;
extern NSString *const kBrandName;
extern NSString *const kSize;
extern NSString *const kPrice;
extern NSString *const kOnSale;
extern NSString *const kCloseout;
extern NSString *const kURL;
extern NSString *const kSpirits;
extern NSString *const kCategory;
extern NSString *const kCount;
extern NSString *const kImageURL;

// Short JSON constants
extern NSString *const kShortName; 
extern NSString *const kShortCount;
extern NSString *const kShortSize;
extern NSString *const kShortPrice;

extern NSString *const kStoreManager;
extern NSString *const kDistrictManager;

// UI Constants
extern NSString *const kMap;
extern NSString *const kList;
extern NSString *const kLoading;
extern NSString *const kCategories;
extern NSString *const kStores;
extern NSString *const kSearch;
extern NSString *const kLocalDistillers;
extern NSString *const kCampaign;

+(NSString *) urlencode: (NSString *) url;
@end
