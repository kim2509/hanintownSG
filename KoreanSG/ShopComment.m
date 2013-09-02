//
//  ShopComment.m
//  KoreanSG
//
//  Created by Daeyong Kim on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShopComment.h"

@implementation ShopComment

@synthesize shopCommentNo, userNo, shopNo, comment, isUse, createDate, updateDate, deleteDate;

- (id)initWithDictionaryValues:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.shopCommentNo = [[dict valueForKey:@"SHOP_COMMENT_NO"] intValue];
        self.userNo = [[dict valueForKey:@"USER_NO"] intValue];
        self.shopNo = [[dict valueForKey:@"SHOP_NO"] intValue];
        
        self.comment = [dict valueForKey:@"COMMENT"];
        
        self.isUse = [dict valueForKey:@"IS_USE"];
        
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

@end
