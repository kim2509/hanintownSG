//
//  NewShop.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewShop.h"


@implementation NewShop

@synthesize newShopSeq, shopSeq, eventYN, dateFrom, dateTo, desc;

- (void)dealloc {
    [eventYN release];
    [dateFrom release];
    [dateTo release];
    [desc release];
    
    [super dealloc];
}

@end
