//
//  NotificationViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 20/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationViewController.h"
#import "MessageListViewController.h"
#import "BoardItemContentViewController.h"

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation NotificationViewController

@synthesize webView;

- (void) viewDidLoad
{
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *cancelButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    cancelButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [cancelButtonCustom addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"닫기";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [cancelButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonCustom];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    self.title = @"알림센터";
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
    [self.view addSubview:webView];
    [webView release];
    
    NSString *urlString = Constants.notificationListURL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    
    NSString *body = [NSString stringWithFormat: @"udid=%@&userID=%@", [[UIDevice currentDevice] uniqueIdentifier] , 
                      [[DataManager sharedDataManager] metaInfoString:@"USER_ID"]];
    
    NSLog(@"UserINFO:%@", body );
    
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    
    [webView  loadRequest:request];
    [webView setDelegate:self];  
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    webView.backgroundColor = [UIColor whiteColor];
    for (UIView* subView in [webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView* shadowView in [subView subviews])
            {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
                }
            }
        }
    }
    
    if (_refreshHeaderView == nil) {
		
        UIScrollView *webScroller = (UIScrollView *)[[webView subviews] objectAtIndex:0];
        [webScroller setDelegate:self];
        
		EGORefreshTableHeaderView *view = 
        [[EGORefreshTableHeaderView alloc] initWithFrame:
         CGRectMake(0.0f, 0.0f - webView.bounds.size.height, self.view.frame.size.width, webView.bounds.size.height)];
        
		view.delegate = self;
		[webScroller addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

-(void) close
{
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (void)setTitle:(NSString *)title
{    
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = [UIColor colorWithHexString:@"#141414"];
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

-(void) viewWillAppear:(BOOL)animated
{
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidUnload
{
    self.webView = nil;
}


#pragma mark WebView Delegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView2
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ( av == nil )
    {
        av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[webView2 addSubview:av];
	[av startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView2
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[webView2 viewWithTag:1];
	[tmpimg removeFromSuperview];
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (void)webView:(UIWebView *)webView2 didFailLoadWithError:(NSError *)error
{
    @try {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[webView2 viewWithTag:1];
        [tmpimg removeFromSuperview];
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        
        NSLog(@"Error:%@", error );
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{    
	if ( navigationType == UIWebViewNavigationTypeBackForward )
	{
	}
	else if ( navigationType == UIWebViewNavigationTypeReload )
	{
	}
	else if ( navigationType == UIWebViewNavigationTypeFormResubmitted )
	{
		
	}
	else if ( navigationType == UIWebViewNavigationTypeLinkClicked || 
			 navigationType == UIWebViewNavigationTypeFormSubmitted ||
			 navigationType == UIWebViewNavigationTypeOther )
	{
        if ( [@"SelectMessage" isEqualToString:[[request.URL absoluteString] lastPathComponent]] )
        {
            NSString *jsCommand = @"document.fm1.type.value;";            
            NSString *type = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
            
            jsCommand = @"document.fm1.isRead.value;";            
            NSString *isRead = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
            
            if ( [@"N" isEqualToString:isRead] )
            {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:
                 [[UIApplication sharedApplication] applicationIconBadgeNumber] - 1];
            }
            
            if ( [type isEqualToString:@"MESSAGE"] )
            {
                MessageListViewController *messageListViewController = [[MessageListViewController alloc] init];
                [self.navigationController pushViewController:messageListViewController animated:YES];
                [messageListViewController release];
            }
            else if ( [type isEqualToString:@"COMMENT"] )
            {
                jsCommand = @"document.fm1.param1.value;";            
                NSString *param1 = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
                
                jsCommand = @"document.fm1.param2.value;";            
                NSString *param2 = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
                
                jsCommand = @"document.fm1.param3.value;";            
                NSString *param3 = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
                
                BoardItemContentViewController *boardItemContentViewController = [[BoardItemContentViewController alloc] init];
                boardItemContentViewController.subject = param3;
                boardItemContentViewController.postID = param2;
                boardItemContentViewController.boardName = param1;
                boardItemContentViewController.userID = [[DataManager sharedDataManager] metaInfoString:@"USER_ID"];
                [self.navigationController pushViewController:boardItemContentViewController animated:YES];
                [boardItemContentViewController release];
            }
            
            return NO;
        }
	}
    
	return YES;
}



#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    [webView reload];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    UIScrollView *webScroller = (UIScrollView *)[[webView subviews] objectAtIndex:0];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:webScroller];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}


- (void)dealloc
{
    [webView release];
    [super dealloc];
}

@end
