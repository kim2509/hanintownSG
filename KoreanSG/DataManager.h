//
//  DataManager.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>
#import "common.h"
#import "DataModel.h"

@interface DataManager : NSObject {
    
}

+(DataManager *) sharedDataManager;
+(NSString *)dataFilePath;

-(void) migrateFrom:(NSString *) fromVersion to:(NSString *) toVersion;

#pragma mark Shop Table methods

-(BOOL)createKoreanShopTable;
- (BOOL) existsKoreanShopTable;
-(BOOL)createNewShopTable;
-(BOOL)createMetaInfoTable;
- (NSMutableArray *) shopListWithCategory:(NSString *) category;
- (NSMutableArray *) shopListFromDBWithNameList:(NSString *) nameList;
- (void) insertAllShopListIntoDBFromFile;
- (NSMutableArray *) shopListFromDBWithCategory:(NSString *) category;
- (Shop *) shopWithSeq:(int) seq;
- (NSMutableArray *) categoryListWithCounts;
-(void) updateShopPriceShowInfo:(NSString *) updateString;
-(void) deleteShops:(NSString *) shopList;
-(void) deleteAllShops;
-(void) updateShopTable;
-(void) dropShopTable;

#pragma mark New Shop Table methods

- (NSMutableArray *) newShopList;
- (NSMutableArray *) newShopListFromDB;
-(int) insertNewShop:(NewShop *)newShop;
- (void) insertNewShopListIntoDBFromFile;
-(void) deleteNewShops:(NSString *) shopList;
-(void) deleteAllNewShop;
-(void) migrateNewShopList;

#pragma mark Favorites Shop Table methods

-(BOOL)createFavoritesShopTable;
-(BOOL) existsInFavorites:(Shop *)shop;
-(int) insertFavoritesShopTable:(Shop *)shop;
-(BOOL) deleteFromFavorites:(Shop *)shop;
-(NSMutableArray *) favoriteShopList;
- (NSMutableArray *) favoriteShopNameList;
-(void) deleteAllFavoritesShops;
-(void) migrateFavoriteShopList;

#pragma mark Menu Table methods

-(BOOL)createMenuTable;
-(void) createMenuTableIndexes;
-(void) insertMenuToDBFromFile;
-(int) insertMenu:(Menu *)menu;
- (NSMutableArray *) menuList:(int) shopSeq;
- (NSMutableArray *) menuListFromFile;
- (NSMutableArray *) menusWithName:(NSString *) menuName ;
- (NSMutableArray *) menuListFromDB:(int) shopSeq;
- (NSMutableArray *) menuGroupList;
- (NSMutableArray *) menuAndGroupList;
- (NSMutableArray *) menuListWithMenuGroup:(MenuGroup *) menuGroup;
-(void) deleteMenus:(NSString *) menuList;
-(void) deleteAllMenus;

#pragma mark MetaInfo Table methods

-(void) setMetaInfo:(NSString *)name value:(NSString *) value;
-(int) insertMetaInfo:(MetaInfo *)metaInfo;
- (MetaInfo *) getMetaInfo:(NSString *) name;
- (NSString *) metaInfoString:(NSString *)name;
-(int) insertKoreanShop:(Shop *)shop;
- (BOOL) getAllShopsInsertedToDB;
-(int) setAllShopsInsertedYES;
- (NSString *) getMenuVersion;
-(void) deleteAllMetaInfo;

- (BOOL) getNewShopsListInsertedToDB;
-(int) setNewShopsListInsertedToDBYES;

#pragma mark Category methods

+(NSString *) categoryNoWithName:(NSString *) categoryName;


#pragma mark SHOP_LIKE TABLE methods

-(BOOL)createShopLikeTable;
-(int) insertShopLike:(ShopLike *)shopLike;
-(int) updateShopLike:(ShopLike *)shopLike;
-(void) deleteShopLikes:(NSString *) shopLikeList;
- (BOOL) doesUserLikeShop:(int) userNo shopNo:(int) shopNo;
-(int) countShopLikes:(int) shopNo;
- (ShopLike *) shopLikeWithUserNo:(int) userNo shopNo:(int) shopNo;

#pragma mark SHOP_COMMENT TABLE methods

-(BOOL)createShopCommentTable;
- (NSMutableArray *) shopCommentsWithSeq:(int) shopSeq;
-(int) insertShopComment:(ShopComment *)shopComment;
-(int) updateShopComment:(ShopComment *)shopComment;
-(void) deleteShopComments:(NSString *) shopCommentList;

#pragma mark SHOP_COMMENT_LIKE TABLE methods

-(BOOL)createShopCommentLikeTable;
-(int) insertShopCommentLike:(ShopCommentLike *)shopCommentLike;
-(void) deleteShopCommentLikes:(NSString *) shopCommentLikeList;

#pragma mark MENU_LIKE TABLE methods

-(BOOL)createMenuLikeTable;
-(int) insertMenuLike:(MenuLike *)menuLike;
-(int) updateMenuLike:(MenuLike *)menuLike;
-(void) deleteMenuLikes:(NSString *) menuLikeList;
- (BOOL) doesUserLikeMenu:(int) userNo menuNo:(int) menuNo;
- (MenuLike *) menuLikeWithUserNo:(int) userNo shopNo:(int) menuNo;
-(int) countMenuLikes:(int) menuNo;

#pragma mark MENU_COMMENT TABLE methods

-(BOOL)createMenuCommentTable;
- (NSMutableArray *) menuCommentsWithSeq:(int) menuSeq;
-(int) insertMenuComment:(MenuComment *)menuComment;
-(int) updateMenuComment:(MenuComment *)menuComment;
-(void) deleteMenuComments:(NSString *) menuCommentList;

#pragma mark MENU_COMMENT_LIKE TABLE methods

-(BOOL)createMenuCommentLikeTable;
-(int) insertMenuCommentLike:(MenuCommentLike *)menuCommentLike;
-(int) updateMenuComment:(MenuComment *)menuComment;
-(void) deleteMenuCommentLikes:(NSString *) menuCommentLikeList;

@end
