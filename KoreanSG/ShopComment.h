//
//  ShopComment.h
//  KoreanSG
//
//  Created by Daeyong Kim on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopComment : NSObject
{
    int shopCommentNo;
    int userNo;
    int shopNo;
    NSString *comment;
    NSString *isUse;
    NSString *createDate;
    NSString *updateDate;
    NSString *deleteDate;
}

@property(nonatomic) int shopCommentNo;
@property(nonatomic) int userNo;
@property(nonatomic) int shopNo;
@property(nonatomic,retain) NSString *comment;
@property(nonatomic,retain) NSString *isUse;
@property(nonatomic,retain) NSString *createDate;
@property(nonatomic,retain) NSString *updateDate;
@property(nonatomic,retain) NSString *deleteDate;

- (id)initWithDictionaryValues:(NSDictionary *) dict;

@end
