//
//  Shop.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Shop.h"
#import "common.h"

@implementation Shop

@synthesize seq, bShowPrice, category,shopName, phone, mobile ,phone1, phone2, address, longitude, 
latitude, email, homepage, menuList, metersFromCurrentLocation, distance, createDate, updateDate, deleteDate,
shopNameEn,categoryEn, nLikes, nComments, bImageExists;

- (id)init {
    self = [super init];
    if (self) {
        category = @"";
        shopName = @"";
        phone = @"";        
        mobile = @"";
        phone1 = @"";
        phone2 = @"";
        address = @"";
        email = @"";
        homepage = @"";
        metersFromCurrentLocation = 0.0;
        distance = @"";
        bShowPrice = YES;
        createDate = @"";
        updateDate = @"";
        deleteDate = @"";
        shopNameEn = @"";
        categoryEn = @"";
        nLikes = 0;
        nComments = 0;
        bImageExists = NO;
    }
    
    return self;
}

- (id)initWithValues:(NSString *) cat name:(NSString *) name  phone:(NSString *) phoneNo address:(NSString *) add
{
    self = [super init];
    if (self) {
        category = cat;
        shopName = name;
        phone1 = phoneNo;
        address = add;
    }
    return self;
}

- (id)initWithDictionaryValues:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.seq = [[dict valueForKey:@"SHOP_NO"] intValue];
        self.shopName = [dict valueForKey:@"SHOP_NAME_KR"];
        self.category = [dict valueForKey:@"CATEGORY_NAME_KR"];
        self.phone = [dict valueForKey:@"PHONE1"];
        self.phone1 = [dict valueForKey:@"PHONE2"];
        self.phone2 = [dict valueForKey:@"PHONE3"];
        self.mobile = [dict valueForKey:@"MOBILE"];
        self.address = [dict valueForKey:@"ADDRESS"];
        self.longitude = [[dict valueForKey:@"LONGITUDE"] doubleValue];
        self.latitude = [[dict valueForKey:@"LATITUDE"] doubleValue];
        self.email = [dict valueForKey:@"EMAIL"];
        self.homepage = [dict valueForKey:@"HOMEPAGE"];
        self.metersFromCurrentLocation = 0.0;
        self.distance = @"";
        bShowPrice = YES;
        bImageExists = NO;
        self.createDate = [dict valueForKey:@"CREATE_DATE"];
        if ( [self.createDate isKindOfClass:[NSNull class]] )
            self.createDate = nil;
        self.updateDate = [dict valueForKey:@"UPDATE_DATE"];
        if ( [self.updateDate isKindOfClass:[NSNull class]] )
            self.updateDate = nil;
        self.deleteDate = [dict valueForKey:@"DELETE_DATE"];
        if ( [self.deleteDate isKindOfClass:[NSNull class]] )
            self.deleteDate = nil;
    }
    return self;
}

- (NSString *)description
{
    NSString *showPriceFlag = @"";
    
    if ( bShowPrice )
        showPriceFlag = @"Y";
    else
        showPriceFlag = @"N";
    
	return [NSString stringWithFormat:@"%d|%@|%@|%@|%@|%@|%@|%@|%f|%f|%@|%@|%@", 
            seq, category, shopName, phone, mobile, phone1, phone2,
			address, longitude, latitude, email, homepage, showPriceFlag];
}

-(NSComparisonResult) compare:(Shop *) shop
{
    if ( latitude == kLocationEmpty )
        return NSOrderedDescending;
    
    if ( shop.latitude == kLocationEmpty )
        return NSOrderedAscending;
    
    if ( metersFromCurrentLocation <= shop.metersFromCurrentLocation )
        return NSOrderedAscending;
    else
        return NSOrderedDescending;
}

-(NSMutableDictionary *) dictionaryValues
{
    NSMutableDictionary *dictValues = [[[NSMutableDictionary alloc] init] autorelease];
    [dictValues setValue:shopName forKey:@"shopNameKR"];
    [dictValues setValue:@"" forKey:@"shopNameEN"];
    [dictValues setValue:[DataManager categoryNoWithName:category] forKey:@"categoryNo"];
    [dictValues setValue:phone forKey:@"phone1"];
    [dictValues setValue:phone1 forKey:@"phone2"];
    [dictValues setValue:phone2 forKey:@"phone3"];
    [dictValues setValue:mobile forKey:@"mobile"];
    [dictValues setValue:address forKey:@"address"];
    [dictValues setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    [dictValues setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
    [dictValues setValue:email forKey:@"email"];
    [dictValues setValue:homepage forKey:@"homepage"];
    
    if ( bShowPrice )
        [dictValues setValue:@"Y" forKey:@"isShowPrice"];
    else
        [dictValues setValue:@"N" forKey:@"isShowPrice"];
    
    return dictValues;
}

- (void)dealloc {
    
    [category release];
    [shopName release];
    [phone release];
    [mobile release];
    [phone1 release];
    [phone2 release];
    [address release];
    [email release];
    [homepage release];
    [menuList release];
    [distance release];
    [createDate release];
    [updateDate release];
    [deleteDate release];
    [shopNameEn release];
    [categoryEn release];
    category = nil;
    shopName = nil;
    phone = nil;
    mobile = nil;
    phone1 = nil;
    phone2 = nil;
    address = nil;
    email = nil;
    homepage = nil;
    menuList = nil;
    distance = nil;
    createDate = nil;
    updateDate = nil;
    shopNameEn = nil;
    categoryEn = nil;
    
    [super dealloc];
}

@end
