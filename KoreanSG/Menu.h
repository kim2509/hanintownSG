//
//  Menu.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Menu : NSObject {
    
    int menuSeq;
    int shopSeq;    
    NSString *menuName;
    NSString *menuUnit;
    NSString *currency;
    float price;
    NSString *menuType;
    NSString *shopName;
    
    BOOL bShowPrice;
    
    int nLikes;
    int nComments;
}

@property(nonatomic) int menuSeq;
@property(nonatomic) int shopSeq;
@property(nonatomic, retain) NSString *menuName;
@property(nonatomic, retain) NSString *menuUnit;
@property(nonatomic, retain) NSString *currency;
@property(nonatomic) float price;
@property(nonatomic, retain) NSString *menuType;
@property(nonatomic, retain) NSString *shopName;
@property(nonatomic) BOOL bShowPrice;
@property(nonatomic) int nLikes;
@property(nonatomic) int nComments;

- (id)initWithDictionaryValues:(NSDictionary *) dict;
-(NSMutableDictionary *) dictionaryValues;

@end
