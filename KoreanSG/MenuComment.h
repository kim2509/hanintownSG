//
//  MenuComment.h
//  KoreanSG
//
//  Created by Daeyong Kim on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuComment : NSObject
{
    int menuCommentNo;
    int userNo;
    int menuNo;
    
    NSString *comment;
    NSString *isUse;
    NSString *createDate;
    NSString *updateDate;
    NSString *deleteDate;
}

@property(nonatomic) int menuCommentNo;
@property(nonatomic) int userNo;
@property(nonatomic) int menuNo;

@property(nonatomic,retain) NSString *comment;
@property(nonatomic,retain) NSString *isUse;
@property(nonatomic,retain) NSString *createDate;
@property(nonatomic,retain) NSString *updateDate;
@property(nonatomic,retain) NSString *deleteDate;

- (id)initWithDictionaryValues:(NSDictionary *) dict;

@end
