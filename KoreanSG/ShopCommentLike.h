//
//  ShopCommentLike.h
//  KoreanSG
//
//  Created by Daeyong Kim on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopCommentLike : NSObject
{
    int shopCommentLikeNo;
    int userNo;
    int shopNo;
    int shopCommentNo;
    NSString *isUse;
    NSString *createDate;
    NSString *updateDate;
    NSString *deleteDate;
}

@property(nonatomic) int shopCommentLikeNo;
@property(nonatomic) int userNo;
@property(nonatomic) int shopNo;
@property(nonatomic) int shopCommentNo;
@property(nonatomic, retain) NSString *isUse;
@property(nonatomic, retain) NSString *createDate;
@property(nonatomic, retain) NSString *updateDate;
@property(nonatomic, retain) NSString *deleteDate;

- (id)initWithDictionaryValues:(NSDictionary *) dict;

@end
