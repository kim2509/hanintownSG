//
//  TransactionOperationManager.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 11. 2..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionOperation.h"
#import "common.h"
#import "DataModel.h"

@interface TransactionManager:NSObject
{
    NSOperationQueue *queue;
}

@property(nonatomic, retain) NSOperationQueue *queue;

+(TransactionManager *) sharedManager;
-(void) getMetaInfoFromServer;
-(void) getUserLikesNComments;

-(void) addNewShop:(Shop *)shop;
-(void) addShopMenu:(Menu *)menu;
-(void) addShopLike:(Shop *) shop shoplike:(ShopLike *)shopLike;
-(void) addShopComment:(Shop *) shop shopComment:(ShopComment *)shopComment;

-(void) addMenuLike:(Menu *) menu shoplike:(MenuLike *)menuLike;
-(void) addMenuComment:(Menu *) menu shopComment:(MenuComment *) menuComment;
-(void) unLikeShop:(ShopLike *)shopLike;
-(void) unLikeMenu:(MenuLike *)menuLike;
-(void) deleteShopComment:(ShopComment *)shopComment;
-(void) deleteMenuComment:(MenuComment *)menuComment;

-(void) getMainInfo;
-(void)getAllServiceMenuWithLevel:(NSString *) level parentID:(NSString *) parentID;

-(void) registerMember:(NSDictionary *) dict;
-(void)login:(NSDictionary *) dict;
-(void)logout:(NSDictionary *) dict;

-(void) getBoardMainInfo;

-(void)getBoardCategory:(NSString *) boardName showAllCategory:(BOOL) bShowAllCategory;
-(void)addBoardPost:(NSDictionary *) dict;
-(void)addReply:(NSDictionary *) dict;
-(void)deleteBoardContent:(NSDictionary *) dict;
-(void)modifyBoardContent:(NSDictionary *) dict;

-(void) sendMessage:(NSNotification *)notification;
-(void)getUserList;

@end
