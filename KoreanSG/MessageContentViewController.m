//
//  MessageContentViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 27/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageContentViewController.h"
#import "MyToolBar.h"

@interface MessageContentViewController ()

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

@implementation MessageContentViewController

@synthesize fromUserID, toUserID, webView;

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
    
    @try {
        UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
        UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
        backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
        [backButtonCustom addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* titleLabel2 = [[[UILabel alloc] 
                                 initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
        titleLabel2.text = @"게시판";
        titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
        titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
        titleLabel2.backgroundColor = [UIColor clearColor];
        titleLabel2.textAlignment = UITextAlignmentCenter;
        
        [backButtonCustom addSubview:titleLabel2];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
        self.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
        
         self.title = @"쪽지함";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(messageSent:) name:@"MessageSent" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(messageReceived:) name:@"MessageReceived" object:nil];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 376)];
        [self.view addSubview:webView];
        [webView release];
        
        NSString *urlString = Constants.messageContentURL;
        NSString *body = [NSString stringWithFormat: @"fromUserID=%@&toUserID=%@&userID=%@", 
                          self.fromUserID, toUserID, [[DataManager sharedDataManager] metaInfoString:@"USER_ID"] ];
        
        NSLog(@"userINFO:%@", body );
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
        [webView  loadRequest:request];
        [webView setDelegate:self];
        
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
        
        [self addCommentView];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception:%@", exception );
    }
    @finally {
        
    }
}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addCommentView
{
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 376, 320, 40)];
    [commentView setBackgroundColor:[UIColor colorWithHexString:@"#EBEDF3"]];
    
    commentField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 255, 30)];
    commentField.borderStyle = UITextBorderStyleRoundedRect;
    commentField.backgroundColor = [UIColor whiteColor];
    commentField.returnKeyType = UIReturnKeySearch;
    commentField.delegate = self;
    commentField.placeholder = @"답변쓰기..";
    commentField.font = [UIFont systemFontOfSize:14];
    commentField.returnKeyType = UIReturnKeySend;
    [commentField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [commentView addSubview:commentField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(265, 5, 50, 30);
    [sendButton setTitle:@"전송" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendButton];
    
    [self.view addSubview:commentView];
}

-(void) viewWillAppear:(BOOL)animated
{
    @try {
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    @try {
        [super viewWillDisappear:animated];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
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
        NSLog(@"%@", request.URL );
        
	}
    
	return YES;
}

-(void) sendMessage
{
    if ( commentField.text == nil || [@"" isEqualToString:commentField.text] )
    {
        NSString *errMsg = [NSString stringWithFormat:@"내용이 없습니다."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:errMsg
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
    [reqDict setValue:[[DataManager sharedDataManager] metaInfoString:@"USER_ID"] forKey:@"fromUserID"];
    
    if ( [[[DataManager sharedDataManager] metaInfoString:@"USER_ID"] isEqualToString:fromUserID] )
        [reqDict setValue:toUserID forKey:@"toUserID"];
    else {
        [reqDict setValue:fromUserID forKey:@"toUserID"];
    }
    
    [reqDict setValue:commentField.text forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessage" object:reqDict];
    commentField.text = @"";
    [commentField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
    // Additional Code
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    @try {
        
        if ( [theTextField returnKeyType] == UIReturnKeySend )
        {
            [self sendMessage];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    
    return YES;
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    if ( keyboardShown )
        return;
    
    if ( activeField != nil ) {
        NSDictionary *info = [aNotification userInfo];
        NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
        
        NSTimeInterval animationDuration = 0.300000011920929;
        CGRect frame = self.view.frame;
        frame.origin.y -= keyboardSize.height-44;
        frame.size.height += keyboardSize.height-44;
        
        CGRect frame2 = commentView.frame;
        frame2.origin.y -= 44;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        commentView.frame = frame2;
        [UIView commitAnimations];
        
        viewMoved = YES;
    }
    
    keyboardShown = YES;
}

- (void)keyboardWasHidden:(NSNotification *)aNotification {
    if ( viewMoved ) {
        NSDictionary *info = [aNotification userInfo];
        NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
        
        NSTimeInterval animationDuration = 0.300000011920929;
        CGRect frame = self.view.frame;
        frame.origin.y += keyboardSize.height-44;
        frame.size.height -= keyboardSize.height-44;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        
        CGRect frame2 = commentView.frame;
        frame2.origin.y += 44;
        commentView.frame = frame2;
        
        [UIView commitAnimations];
        
        viewMoved = NO;
    }
    
    keyboardShown = NO;
}


-(void) messageSent:(NSNotification *)notification
{
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
          :UIActivityIndicatorViewStyleGray];
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];
}

-(void) messageReceived:(NSNotification *)notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            [webView reload];
        }
        else if ([ErrCodeFail isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            
            NSString *errMsg = [NSString stringWithFormat:@"서버와의 통신이 원활하지 않습니다.\n잠시 후 다시 시도해 주십시오.(%@)", 
                                [resDict objectForKey:@"resCode"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];            
        }
        else {
            
            NSString *errMsg = [NSString stringWithFormat:@"%@(%@)", [resDict objectForKey:@"resMsg"],
                                [resDict objectForKey:@"resCode"]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];
        }   
    }
    @catch (NSException *exception) {
        NSLog(@"[httpRequestReceived exception]: %@", exception);
    }
    @finally {
        
    }
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

@end
