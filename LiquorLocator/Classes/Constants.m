//
//  Constants.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/9/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "Constants.h"


@implementation Constants
    NSString *const kId = @"id";
    NSString *const kName = @"name";
    NSString *const kStore = @"store";
    NSString *const kQty = @"qty";
    NSString *const kDist = @"dist";
    NSString *const kStreet = @"street";
    NSString *const kAddress = @"address";
    NSString *const kAddress2 = @"address2";
    NSString *const kCity = @"city";
    NSString *const kZip = @"zip";
    NSString *const kLat = @"lat";
    NSString *const kLong = @"long";
    NSString *const kContacts = @"contacts";
    NSString *const kRole = @"role";
    NSString *const kNumber = @"number";
    NSString *const kHours = @"hours";
    NSString *const kStartDay = @"start_day";
    NSString *const kEndDay = @"end_day";
    NSString *const kOpen = @"open";
    NSString *const kClose = @"close";
    NSString *const kBrandName = @"brand_name";
    NSString *const kSize = @"size";
    NSString *const kPrice = @"price";
    NSString *const kOnSale = @"on_sale";
    NSString *const kCloseout = @"closeout";
    NSString *const kURL = @"url";
    NSString *const kSpirits = @"spirits";
    NSString *const kCategory = @"cat";
    NSString *const kCount = @"count";

    NSString *const kShortName = @"n";
    NSString *const kShortCount = @"c";
    NSString *const kShortSize = @"s";
    NSString *const kShortPrice = @"p";

    NSString *const kStoreManager = @"Store Manager";
    NSString *const kDistrictManager = @"District Manager";

    NSString *const kMap = @"Map";
    NSString *const kList = @"List";
    NSString *const kLoading = @"Loading";
    NSString *const kCategories = @"Categories";
    NSString *const kStores = @"Stores";
    NSString *const kSearch = @"Search";
    NSString *const kLocalDistillers = @"Washington State Distillers";
    NSString *const kCampaign = @"Campaign";

#pragma mark -
#pragma mark URL String encoding
+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,
                            @"$" , @"," , @"[" , @"]",
                            @"#", @"!", @"'", @"(", 
                            @")", @"*", @" ", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
                             @"%3A" , @"%40" , @"%26" ,
                             @"%3D" , @"%2B" , @"%24" ,
                             @"%2C" , @"%5B" , @"%5D", 
                             @"%23", @"%21", @"%27",
                             @"%28", @"%29", @"%2A", @"+", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [url mutableCopy];
    
    int i;
    for(i = 0; i < len; i++)
    {
        
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    NSString *out = [NSString stringWithString: temp];
    
    return out;
}

@end
