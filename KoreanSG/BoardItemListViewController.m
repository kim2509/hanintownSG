//
//  BoardItemListViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoardItemListViewController.h"
#import "NewPostViewController.h"
#import "CategorySelectViewController.h"
#import "BoardItemContentViewController.h"

@interface BoardItemListViewController ()

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

@implementation BoardItemListViewController

@synthesize boardWebView, boardName, menuName;

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
    
    self.boardWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 376)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        boardWebView.frame = CGRectMake(boardWebView.frame.origin.x, boardWebView.frame.origin.y,
                                       boardWebView.frame.size.width, boardWebView.frame.size.height + 90 );
    }
    
    [self.view addSubview:boardWebView];
    [boardWebView release];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSString *urlString = Constants.boardItemListURL;
    
    NSString *body = [NSString stringWithFormat: @"categoryID=%@&boardName=%@", 
                      [[DataManager sharedDataManager] metaInfoString:[NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]],
                      boardName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [boardWebView  loadRequest:request];
    [request release];
        
    [boardWebView setDelegate:self];
    
    boardWebView.backgroundColor = [UIColor whiteColor];
    for (UIView* subView in [boardWebView subviews])
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
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                            initWithFrame:CGRectMake(5, 0, 63, 32 )];
    titleLabel2.text = @"Home";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    [backButtonCustom addSubview:titleLabel2];
    [titleLabel2 release];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    self.title = menuName;
    
    bNewPostClicked = NO;
    
    if (_refreshHeaderView == nil) {
        
        UIScrollView *webScroller = (UIScrollView *)[[boardWebView subviews] objectAtIndex:0];
        [webScroller setDelegate:self];
        
        EGORefreshTableHeaderView *view = 
        [[EGORefreshTableHeaderView alloc] initWithFrame:
         CGRectMake(0.0f, 0.0f - boardWebView.bounds.size.height, self.view.frame.size.width, boardWebView.bounds.size.height)];
        
        view.delegate = self;
        [webScroller addSubview:view];
        _refreshHeaderView = view;
        [view release];
        
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [topBar setBackgroundColor:[UIColor colorWithHexString:@"#EBEDF3"]];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
    [bottomLine setBackgroundColor:[UIColor colorWithHexString:@"#B0B0B0"]];
    [topBar addSubview:bottomLine];
    [bottomLine release];
    
    UIButton *newPostButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newPostButton.frame = CGRectMake(210, 5, 50, 30);
    [newPostButton setTitle:@"글쓰기" forState:UIControlStateNormal];
    [newPostButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:newPostButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchButton.frame = CGRectMake(265, 5, 50, 30);
    [searchButton setTitle:@"검색" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:searchButton];
    
    UIView *categorySelectView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 80, 30)];
    categorySelectView.layer.cornerRadius = 5.0;
    categorySelectView.backgroundColor = [UIColor whiteColor];
    categorySelectView.layer.borderColor = [UIColor colorWithHexString:@"#003366"].CGColor;
    categorySelectView.layer.borderWidth = 0.5f;
    categorySelectView.userInteractionEnabled = YES;
    UITapGestureRecognizer *editGesture =
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCategory)] autorelease];
    [categorySelectView addGestureRecognizer:editGesture];
    
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 20)];
    categoryLabel.textAlignment = UITextAlignmentCenter;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont boldSystemFontOfSize:14];
    
    NSString *category = [[DataManager sharedDataManager] metaInfoString:[NSString stringWithFormat:@"%@_CATEGORY_NAME", boardName]];
    if ( category == nil || [category isEqualToString:@""] )
    {
        category = @"전체";
    }
    
    categoryLabel.text = [NSString stringWithFormat:@"%@", category];
    categoryLabel.textColor = [UIColor colorWithHexString:@"#003366"];
    [categorySelectView addSubview:categoryLabel];
    [topBar addSubview:categorySelectView];
    [categorySelectView release];
    
    [self.view addSubview:topBar];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CategoryChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categoryChanged:) name:@"CategoryChanged" object:nil];
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

- (void) goHome
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{ 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addBoardPost:) name:@"NewPost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(httpRequestSent:) name:@"HttpRequestSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(httpRequestReceived:) name:@"HttpRequestReceived" object:nil];
}

- (void)progress:(int)progress withMessage:(NSString*)message {
    UIView* v = [[[UIView alloc] init] autorelease];
    v.frame = CGRectMake(20, 0, 100, 30);
    v.backgroundColor = [UIColor clearColor];
    
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    lbl.frame = CGRectMake(0,0, 100, 15);
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    lbl.shadowOffset = CGSizeMake(0, -1);
    lbl.font = [UIFont boldSystemFontOfSize:12];
    lbl.textColor = [UIColor colorWithHexString:@"#141414"];
    lbl.text = message;
    lbl.textAlignment = UITextAlignmentCenter;
    [v addSubview:lbl];
    
    UIProgressView* pv = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    pv.frame = CGRectMake(0, 30-pv.frame.size.height, 100, pv.frame.size.height);
    pv.progress = progress/100.0;
    pv.tag = 1;
    [v addSubview:pv];
    
    self.navigationItem.titleView = v;
}

-(void) addBoardPost:(NSNotification *)notification
{
    @try {
        
        NSMutableDictionary *dict = notification.object;
        
        NSURL *url = [NSURL URLWithString:[Constants addBoardPostURL]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request addRequestHeader: @"Content-Type" value:@"multipart/form-data;"];
        [request setPostFormat:ASIMultipartFormDataPostFormat];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request setResponseEncoding:NSUTF8StringEncoding];
        
        DataManager *dataManager = [DataManager sharedDataManager];
        
        [request addPostValue:[dataManager metaInfoString:@"USER_NO"] forKey:@"userNo"];
        [request addPostValue:[dataManager metaInfoString:@"USER_ID"] forKey:@"userID"];
        [request addPostValue:[dataManager metaInfoString:@"USER_DEVICE_TOKEN"] forKey:@"userDeviceToken"];
        [request addPostValue:[dataManager metaInfoString:@"NICKNAME"] forKey:@"nickName"];
        [request addPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"iOSVersion"];
        [request addPostValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
        [request addPostValue:[Constants getClientVersion] forKey:@"ClientVersion"];
        
        [request addPostValue:[dict objectForKey:@"subject"] forKey:@"subject"];
        [request addPostValue:[dict objectForKey:@"content"] forKey:@"content"];
        [request addPostValue:[dict objectForKey:@"bodyTextOrder"] forKey:@"bodyTextOrder"];
        [request addPostValue:[dict objectForKey:@"categoryID"] forKey:@"categoryID"];
        [request addPostValue:[dict objectForKey:@"boardName"] forKey:@"boardName"];
        
        NSArray *ar = [dict objectForKey:@"images"];
        for ( int i = 0; i < [ar count]; i++ )
            [request addData:[ar objectAtIndex:i] withFileName:[NSString stringWithFormat:@"img%d", i] 
              andContentType:@"image/jpeg" forKey:@"image[]"];
  
        [self progress:0 withMessage:@"uploading.."];
        request.uploadProgressDelegate = [self.navigationItem.titleView viewWithTag:1];
        
        [request startAsynchronous];
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
        
        [request setCompletionBlock:^{
            
            self.navigationItem.titleView = nil;
            self.title = menuName;
            
            NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
            
            NSMutableDictionary *resultHeader = [array objectAtIndex:0];
            [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
            [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
            
        }];
        
        [request setFailedBlock:^{
            
            self.navigationItem.titleView = nil;
            self.title = menuName;
            
            [resultDict setValue:@"9999" forKey:@"resCode"];
            [resultDict setValue:[request error] forKey:@"resMsg"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

-(void) showNewPostViewController
{
    NewPostViewController *newPostViewController = [[NewPostViewController alloc] init];
    newPostViewController.boardName = boardName;
    UINavigationController *newPostNavViewController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    [newPostViewController release];
    
    newPostNavViewController.title = @"새 글";
    [[self navigationController] presentModalViewController:newPostNavViewController animated:YES];
    [newPostNavViewController release];
}

-(void) viewDidAppear:(BOOL)animated
{
    if ( [self isAlreadyLogin] && bNewPostClicked )
    {
        [self showNewPostViewController];
        bNewPostClicked = NO;
    }
}

-(void) newPost
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        
        bNewPostClicked = YES;
    }
    else {
        [self showNewPostViewController];
    }
}

-(void) changeCategory
{
    CategorySelectViewController *categorySelectViewController = [[CategorySelectViewController alloc] init];
    categorySelectViewController.boardName = boardName;
    categorySelectViewController.bShowAllCategory = YES;
    categorySelectViewController.callFrom = @"listView";
    UINavigationController *categorySelectNavViewController = 
    [[UINavigationController alloc] initWithRootViewController:categorySelectViewController];
    [categorySelectViewController release];
    [[self navigationController] presentModalViewController:categorySelectNavViewController animated:YES];
    [categorySelectNavViewController release];
}

-(void) categoryChanged:(NSNotification *) notification
{
    categoryLabel.text = [[DataManager sharedDataManager] metaInfoString:[NSString stringWithFormat:@"%@_CATEGORY_NAME", boardName]];
    
    NSString *urlString = Constants.boardItemListURL;
    NSString *body = [NSString stringWithFormat: @"categoryID=%@&boardName=%@", 
                      [[DataManager sharedDataManager] metaInfoString:[NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]],
                      boardName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [boardWebView  loadRequest:request];
    [request release];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewPost" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HttpRequestSent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HttpRequestReceived" object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"viewdidunloaded.");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.boardWebView = nil;
    self.menuName = nil;
    self.boardName = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *) contentType: (NSURLResponse *) response  
{
    if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
        
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        
        for (NSString *key in headers ) {
            NSLog(@"key:%@ value:%@", key, [headers objectForKey:key] );
        }
        
        NSString *contentType = [headers objectForKey:@"Content-Type"];
        
        return contentType;
    }
    else {
        return nil;
    }
}

-(void) dealloc
{
    [boardWebView release];
    [menuName release];
    [boardName release];
    [super dealloc];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
    }
}

-(void) httpRequestSent:(NSNotification *)notification
{
    if ( av == nil )
    {
        av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    av.frame=CGRectMake(130, 180, 50, 50);
    av.tag  = 1;
    [self.view addSubview:av];
    [av startAnimating];
}


-(void) httpRequestReceived:(NSNotification *)notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            [boardWebView reload];
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

-(void) search
{
    topBar.hidden = YES;
    
    if ( searchView == nil )
    {
        searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 75)];
        [searchView setBackgroundColor:[UIColor colorWithHexString:@"#EBEDF3"]];    
        searchField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 255, 30)];
        searchField.borderStyle = UITextBorderStyleRoundedRect;
        searchField.backgroundColor = [UIColor whiteColor];
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.delegate = self;
        [searchField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [searchView addSubview:searchField];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(265, 5, 50, 30);
        [button setTitle:@"취소" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
        [searchView addSubview:button];
        
        darkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        darkView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        darkView.opaque = NO;
        darkView.userInteractionEnabled = YES;
        UITapGestureRecognizer *cancelSearchGesture =
        [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewSearchResult)] autorelease];
        [darkView addGestureRecognizer:cancelSearchGesture];
        
        NSArray *searchItems = [NSArray arrayWithObjects:@"제목+내용", @"글쓴이",nil];
        
        searchOption = [[UISegmentedControl alloc] initWithItems:searchItems];
        CGRect viewOptionRect = CGRectMake(5, 40, 130, 30);
        [searchOption setFrame:viewOptionRect];
        searchOption.segmentedControlStyle = UISegmentedControlStyleBar;
        searchOption.selectedSegmentIndex = 0;
        
        [searchView addSubview:searchOption];
        
        searchViewBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 74, 320, 1)];
        [searchViewBottomLine setBackgroundColor:[UIColor colorWithHexString:@"#B0B0B0"]];
        [searchView addSubview:searchViewBottomLine];
    }
    
    searchView.frame = CGRectMake(0, 0, 320, 75);
    searchOption.hidden = NO;
    searchViewBottomLine.frame = CGRectMake(0, 74, 320, 1);
    
    [self.view addSubview:searchView];
    [boardWebView addSubview:darkView];
    [searchField becomeFirstResponder];
}

- (void) cancelSearch
{
    [darkView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    [searchView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    topBar.hidden = NO;
    
    NSString *urlString = Constants.boardItemListURL;
    NSString *body = [NSString stringWithFormat: @"categoryID=%@&boardName=%@", 
                      [[DataManager sharedDataManager] metaInfoString:[NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]],
                      boardName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [boardWebView  loadRequest:request];
    [request release];
}

- (void) viewSearchResult
{
    [searchField resignFirstResponder];    
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    searchView.frame = CGRectMake(0, 0, 320, 75);
    searchOption.hidden = NO;
    searchViewBottomLine.frame = CGRectMake(0, 74, 320, 1);
    
    [boardWebView addSubview:darkView];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if ( [theTextField returnKeyType] == UIReturnKeyNext )
    {
        
    }
    else if ( [theTextField returnKeyType] == UIReturnKeySend )
    {
        
    }
    else if ( [theTextField returnKeyType] == UIReturnKeySearch )
    {
        CGRect rect = searchView.frame;
        rect.size.height = 40;
        searchView.frame = rect;
        searchOption.hidden = YES;
        CGRect rect2 = searchViewBottomLine.frame;
        rect2.origin.y = 39;
        searchViewBottomLine.frame = rect2;
        
        NSString *urlString = Constants.searchBoardURL;
        NSString *body = [NSString stringWithFormat: @"searchKeywordType=%@&searchKeyword=%@&udid=%@&userID=%@&boardName=%@", 
                          (searchOption.selectedSegmentIndex == 0) ? @"CONTENT":@"AUTHOR" , searchField.text,
                          [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                          [[DataManager sharedDataManager] metaInfoString:@"USER_ID"], boardName];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [boardWebView  loadRequest:request];
        [request release];
        
        [searchField resignFirstResponder];
        [darkView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    }
    
    return YES;
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
        if ( [@"DisplayContent" isEqualToString:[[request.URL absoluteString] lastPathComponent]] )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *jsCommand = @"document.fm1.subject.value;";            
            NSString *subject = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            jsCommand = @"document.fm1.post_id.value;";            
            NSString *postID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            jsCommand = @"document.fm1.userID.value;";            
            NSString *userID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            jsCommand = @"document.fm1.boardName.value;";
            NSString *selectedBoardName = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            BoardItemContentViewController *boardItemContentViewController = [[BoardItemContentViewController alloc] init];
            boardItemContentViewController.subject = subject;
            boardItemContentViewController.postID = postID;
            boardItemContentViewController.boardName = selectedBoardName;
            boardItemContentViewController.userID = userID;
            [self.navigationController pushViewController:boardItemContentViewController animated:YES];
            [boardItemContentViewController release];
            
            return NO;
        }
        else if ( [[[request.URL absoluteString] lastPathComponent] rangeOfString:@"#top"].length > 0 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    [boardWebView reload];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    UIScrollView *webScroller = (UIScrollView *)[[boardWebView subviews] objectAtIndex:0];
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