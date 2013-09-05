//
//  Constants.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#define kDBFileName @"KoreanSG.sqlite3"

#define kLocationEmpty -12345
#define ErrCodeSuccess @"0000"
#define ErrCodeFail @"9999"

#define ServerUrl @"http://www.hanintownsg.com"
//#define ServerUrl @"http://192.168.10.105:8888"

#define SCSessionStateChangedNotification @"com.facebook.Scrumptious:SCSessionStateChangedNotification"

@interface Constants : NSObject {
    
    
    
}

+(NSString *) getClientVersion;
+(NSString *) metaInfoURL;
+(NSString *) userLikesNCommentsURL;

+(NSString *) getAllServiceMenu;

+(NSString *) mainInfo;

#pragma mark USER related URLs

+(NSString *) registerMemberURL;
+(NSString *) loginURL;
+(NSString *) logoutURL;
+(NSString *) sendMessageURL;
+(NSString *) messageListURL;
+(NSString *) messageContentURL;
+(NSString *) userListURL;
+(NSString *) notificationListURL;

#pragma mark BOARD related URLs

+(NSString *) boardMainInfo;
+(NSString *) boardCategoryURL;
+(NSString *) boardItemListURL;
+(NSString *) addBoardPostURL;
+(NSString *) searchBoardURL;
+(NSString *) boardContentURL;
+(NSString *) modifyBoardContentURL;
+(NSString *) addReplyURL;
+(NSString *) deleteBoardContentURL;

#pragma SHOP related URLs
+(NSString *) addShopLikeURL;
+(NSString *) unlikeShopURL;
+(NSString *) addShopCommentURL;
+(NSString *) deleteShopComment;
+(NSString *) shopImageURL:(int) shopSeq;
+(NSString *) uploadShopImageURL;

#pragma MENU related URLs
+(NSString *) addMenuLikeURL;
+(NSString *) unlikeMenuURL;
+(NSString *) addMenuCommentURL;
+(NSString *) deleteMenuComment;
+(NSString *) menuImageURL:(int) menuSeq;
+(NSString *) uploadMenuImageURL;

@end
