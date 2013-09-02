//
//  Menu.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"


@implementation Menu

@synthesize menuSeq, shopSeq, menuName, menuUnit, currency, price, menuType, shopName, bShowPrice, nLikes, nComments;

- (void)dealloc {
    
    [menuName release];
    [menuUnit release];
    [currency release];
    [menuType release];
    [shopName release];
    
    [super dealloc];
}

- (id)initWithDictionaryValues:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        
        self.menuSeq = [[dict valueForKey:@"MENU_NO"] intValue];
        self.shopSeq = [[dict valueForKey:@"SHOP_NO"] intValue];
        self.menuName = [dict valueForKey:@"MENU_NAME_KR"];
        self.menuUnit = [dict valueForKey:@"MENU_UNIT"];
        self.currency = [dict valueForKey:@"CURRENCY_NAME"];
        self.price = [[dict valueForKey:@"PRICE"] doubleValue];
        self.menuType = [dict valueForKey:@"MENU_TYPE"];        
        
        nLikes = 0;
        nComments = 0;
    }
    return self;
}

-(NSMutableDictionary *) dictionaryValues
{
    NSMutableDictionary *dictValues = [[[NSMutableDictionary alloc] init] autorelease];
    [dictValues setValue:[NSString stringWithFormat:@"%d", shopSeq] forKey:@"shopNo"];
    [dictValues setValue:menuName forKey:@"menuNameKR"];
    [dictValues setValue:@"" forKey:@"menuNameEN"];
    [dictValues setValue:menuType forKey:@"menuType"];
    [dictValues setValue:@"N" forKey:@"isLunch"];
    [dictValues setValue:currency forKey:@"currencyCode"];
    [dictValues setValue:menuUnit forKey:@"menuUnit"];
    [dictValues setValue:[NSString stringWithFormat:@"%f", price] forKey:@"price"];
    [dictValues setValue:@"" forKey:@"menuDesc"];
    
    return dictValues;
}

- (NSString *)description
{ 
	return [NSString stringWithFormat:@"%d|%d|%@|%@|%@|%0.1f|%@", 
            menuSeq, shopSeq, menuName, menuUnit, currency, price, menuType];
}

@end
