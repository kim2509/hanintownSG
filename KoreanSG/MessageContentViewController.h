//
//  MessageContentViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 27/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "EGORefreshTableHeaderView.h"

@interface MessageContentViewController : DYViewController<UIWebViewDelegate,UITextFieldDelegate,
                                EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    UIWebView *webView;
    NSString *fromUserID;
    NSString *toUserID;
    UITextField *commentField;
    UITextField *activeField;
    BOOL bScrollToBottom;
    BOOL keyboardShown;
    BOOL viewMoved;
    
    UIView *commentView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
}

@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *fromUserID;
@property(nonatomic, retain) NSString *toUserID;

@end
