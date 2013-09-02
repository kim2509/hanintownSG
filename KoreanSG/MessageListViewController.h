//
//  MessageListViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 24/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "EGORefreshTableHeaderView.h"

@interface MessageListViewController : DYViewController<UIWebViewDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    UIWebView *webView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
}

@property(nonatomic, retain) UIWebView *webView;

@end
