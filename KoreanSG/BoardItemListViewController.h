//
//  FreeBoardViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "EGORefreshTableHeaderView.h"

@interface BoardItemListViewController : DYViewController<UIWebViewDelegate, UIAlertViewDelegate, UITextFieldDelegate,
EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    UIWebView *boardWebView;
    BOOL bNewPostClicked;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
    
    UIView *topBar;
    UIView *searchView;
    UITextField *searchField;
    UIView *darkView;
    UILabel *categoryLabel;
    UISegmentedControl *searchOption;
    UIView *searchViewBottomLine;
    
    NSString *menuName;
    NSString *boardName;
}

@property(nonatomic, retain) UIWebView *boardWebView;
@property(nonatomic, retain) NSString *menuName;
@property(nonatomic, retain) NSString *boardName;

- (NSString *) contentType: (NSURLResponse *) response;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
