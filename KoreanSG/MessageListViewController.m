//
//  MessageListViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 24/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageContentViewController.h"

@interface MessageListViewController ()

@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation MessageListViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
    titleLabel.text = @"Home";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *writeButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    writeButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [writeButtonCustom addTarget:self action:@selector(openSendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel2.text = @"새 쪽지";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [writeButtonCustom addSubview:titleLabel2];
    [titleLabel2 release];
    
    UIBarButtonItem *writeButton = [[UIBarButtonItem alloc] initWithCustomView:writeButtonCustom];
    self.navigationItem.rightBarButtonItem = writeButton;
    [writeButton release];
    
    self.title = @"쪽지함";
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
    [self.view addSubview:webView];
    [webView release];
    
    NSString *urlString = Constants.messageListURL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    
    NSString *body = [NSString stringWithFormat: @"udid=%@&userID=%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString] , 
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

- (void) goHome
{
    [self.navigationController popViewControllerAnimated:YES];
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
    @try {
         
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        if ( [@"DisplayMessage" isEqualToString:[[request.URL absoluteString] lastPathComponent]] )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *jsCommand = @"document.fm1.fromUserID.value;";            
            NSString *fromUserID = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
            jsCommand = @"document.fm1.toUserID.value;";            
            NSString *toUserID = [webView2 stringByEvaluatingJavaScriptFromString:jsCommand];
            
            MessageContentViewController *messageContentViewController = [[MessageContentViewController alloc] init];
            messageContentViewController.fromUserID = fromUserID;
            messageContentViewController.toUserID = toUserID;
            [self.navigationController pushViewController:messageContentViewController animated:YES];
            [messageContentViewController release];
            
            return NO;
        }
	}
    
	return YES;
}

-(void) openSendMessage
{
    [super openSendMessageViewController:@"" nickName:@""];
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
