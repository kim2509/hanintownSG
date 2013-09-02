//
//  NewShop.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewShop : NSObject {
    
    int newShopSeq;
    int shopSeq;
    NSString *eventYN;
    NSString *dateFrom;
    NSString *dateTo;
    NSString *desc;
}

@property(nonatomic) int newShopSeq;
@property(nonatomic) int shopSeq;
@property(nonatomic, retain) NSString *eventYN;
@property(nonatomic, retain) NSString *dateFrom;
@property(nonatomic, retain) NSString *dateTo;
@property(nonatomic, retain) NSString *desc;

@end