//
//  BoardItemContentViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "EGORefreshTableHeaderView.h"

@interface BoardItemContentViewController : DYViewController<UIWebViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,
UIAlertViewDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    UIWebView *boardWebView;
    NSString *subject;
    NSString *postID;
    NSString *userID;
    NSString *boardName;
    UITextField *activeField;
    BOOL keyboardShown;
    BOOL viewMoved;
    
    UIView *commentView;
    UITextField *commentField;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
}

@property(nonatomic, retain) NSString *subject;
@property(nonatomic, retain) NSString *postID;
@property(nonatomic, retain) NSString *userID;
@property(nonatomic, retain) NSString *boardName;
@property(nonatomic, retain) UIWebView *boardWebView;

@end
