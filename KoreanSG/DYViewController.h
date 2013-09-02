//
//  DYViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYViewController : UIViewController
{
    UIActivityIndicatorView *av;
}

@property (nonatomic, retain) UIActivityIndicatorView *av;

-(void) openSendMessageViewController:(NSString *) userID nickName:(NSString *)nickName;
-(void) openUserListViewController;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
-(void) showModalLoginViewController;
-(void) showNotificationViewController:(BOOL) animated;
-(BOOL) isAlreadyLogin;
- (void) appBecomeForeground:(NSNotification *) notification;

+ (void) setBoardCategoryList:(NSMutableArray *) list;
+(NSMutableArray *) getBoardCategoryList:(NSString *) boardName showOptional:(BOOL) bShowOptional;

@end
