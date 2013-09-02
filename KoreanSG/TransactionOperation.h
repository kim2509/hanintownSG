//
//  TransactionOperation.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 11. 2..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

#define kUpdateShopInfo 1
#define kUpdateUserLikesNComments 2

@interface TransactionOperation : NSOperation
{

    int TRANS_MODE;
    NSString *responseString;
    
    BOOL shopLikesNCommentsUpdated;
    BOOL menuLikesNCommentsUpdated;
}

@property(nonatomic, retain) NSString *responseString;

-(void) setUpdateShopInfoData:(NSString *) respString;
-(void) updateMetaInfo;
-(void) updateShopInfo;
-(void) updateMenuInfo;
-(void) updateNewShopInfo;
-(void) setUserLikesNComments:(NSString *) respString;

-(void) initVariables;
-(BOOL) needsUpdateForLikesNComments;

-(void) updateShopLikes;
-(void) updateShopComments;
-(void) updateShopCommentLikes;
-(void) updateMenuLikes;
-(void) updateMenuComments;
-(void) updateMenuCommentLikes;
@end
