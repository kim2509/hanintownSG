//
//  Shop.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Menu;
@interface Shop : NSObject {
    int seq;
    NSString *category;
    NSString *shopName;
    NSString *phone;
    NSString *mobile;
    NSString *phone1;
    NSString *phone2;
    NSString *address;
    double longitude;
    double latitude;
    NSString *email;
    NSString *homepage;
    NSMutableArray *menuList;
    
    double metersFromCurrentLocation;
    NSString *distance;
    
    BOOL bShowPrice;
    BOOL bImageExists;
    
    NSString *createDate;
    NSString *updateDate;
    NSString *deleteDate;
    NSString *shopNameEn;
    NSString *categoryEn;
    
    int nLikes;
    int nComments;
}

@property(nonatomic) int seq;
@property(nonatomic) BOOL bShowPrice;
@property(nonatomic) BOOL bImageExists;
@property(nonatomic, retain) NSString *category;
@property(nonatomic, retain) NSString *shopName;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *mobile;
@property(nonatomic, retain) NSString *phone1;
@property(nonatomic, retain) NSString *phone2;
@property(nonatomic, retain) NSString *address;
@property(nonatomic) double longitude;
@property(nonatomic) double latitude;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *homepage;
@property(nonatomic, retain) NSMutableArray *menuList;
@property(nonatomic) double metersFromCurrentLocation;
@property(nonatomic, retain) NSString *distance;
@property(nonatomic, retain) NSString *createDate;
@property(nonatomic, retain) NSString *updateDate;
@property(nonatomic, retain) NSString *deleteDate;
@property(nonatomic, retain) NSString *shopNameEn;
@property(nonatomic, retain) NSString *categoryEn;
@property(nonatomic) int nLikes;
@property(nonatomic) int nComments;

- (id)initWithValues:(NSString *) cat name:(NSString *) name  phone:(NSString *) phoneNo address:(NSString *) add;
- (id)initWithDictionaryValues:(NSDictionary *) dict;
-(NSMutableDictionary *) dictionaryValues;

@end
