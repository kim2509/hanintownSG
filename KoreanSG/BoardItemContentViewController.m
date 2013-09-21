//
//  BoardItemContentViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoardItemContentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NewPostViewController.h"
#import "SendMessageViewController.h"

@interface BoardItemContentViewController ()

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

@implementation BoardItemContentViewController


@synthesize postID, boardWebView, boardName, userID, subject;

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
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [optionButton setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    optionButton.frame = CGRectMake(0.0, 0.0, 63, 32);
    [optionButton addTarget:self action:@selector(optionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if ( [[[DataManager sharedDataManager] metaInfoString:@"USER_ID"] isEqualToString:userID] )
    {
        UILabel* menuLabel = [[[UILabel alloc] 
                               initWithFrame:CGRectMake(5, 0, 53, 32 )] autorelease];
        menuLabel.text = @"수정/삭제";
        menuLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
        menuLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
        menuLabel.backgroundColor = [UIColor clearColor];
        menuLabel.textAlignment = UITextAlignmentCenter;
        
        [optionButton addSubview:menuLabel];
        
        UIBarButtonItem *optionBarButton = [[UIBarButtonItem alloc] initWithCustomView:optionButton];
        self.navigationItem.rightBarButtonItem = optionBarButton;
        [optionBarButton release];
    }
    
    self.title = subject;
    
    boardWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 376)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        boardWebView.frame = CGRectMake(boardWebView.frame.origin.x, boardWebView.frame.origin.y,
                                       boardWebView.frame.size.width, boardWebView.frame.size.height + 90 );
    }
    
    [self.view addSubview:boardWebView];
    
    NSString *urlString = Constants.boardContentURL;
    NSString *body = [NSString stringWithFormat: @"postID=%@&udid=%@&userID=%@&nickName=%@&boardName=%@", 
                      self.postID, [[[UIDevice currentDevice] identifierForVendor] UUIDString] ,
                      [[DataManager sharedDataManager] metaInfoString:@"USER_ID"],
                      [[DataManager sharedDataManager] metaInfoString:@"NICKNAME"], boardName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [boardWebView  loadRequest:request];
    [boardWebView setDelegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
    
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
    
    [self addCommentView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(httpRequestSent:) name:@"HttpRequestSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(httpRequestReceived:) name:@"HttpRequestReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(modifyPost:) name:@"ModifyPost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginSucceeded:) name:@"LoginSucceeded" object:nil];
}

-(void) addCommentView
{
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 376, 320, 40)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y + 90 ,
                                        commentView.frame.size.width, commentView.frame.size.height );
    }
    
    [commentView setBackgroundColor:[UIColor colorWithHexString:@"#EBEDF3"]];
    
    commentField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 255, 30)];
    commentField.borderStyle = UITextBorderStyleRoundedRect;
    commentField.backgroundColor = [UIColor whiteColor];
    commentField.returnKeyType = UIReturnKeySearch;
    commentField.delegate = self;
    commentField.placeholder = @"댓글달기..";
    commentField.font = [UIFont systemFontOfSize:14];
    commentField.returnKeyType = UIReturnKeySend;
    [commentField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [commentView addSubview:commentField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(265, 5, 50, 30);
    [sendButton setTitle:@"전송" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendButton];
    
    [self.view addSubview:commentView];
}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) optionButtonClicked
{
    @try {
        
        if ( [self isAlreadyLogin] == NO )
        {
            [self showModalLoginViewController];
            return;
        }
        
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" 
                                                                delegate:self 
                                                       cancelButtonTitle:@"취소" 
                                                  destructiveButtonTitle:@"삭제"
                                                       otherButtonTitles:@"수정", nil];
        
        popupQuery.tag = 1;
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        [popupQuery showInView:self.view];
        [popupQuery release];   
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void) deleteContent
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"정말로 삭제하시겠습니까?" message:nil 
                                                   delegate:self cancelButtonTitle:@"Yes" 
                                          otherButtonTitles:@"No",nil];
    
    [alert show];
    [alert autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
        [reqDict setValue:postID forKey:@"bID"];
        [reqDict setValue:boardName forKey:@"boardName"];
        [[TransactionManager sharedManager] deleteBoardContent:reqDict];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

-(void) showNewPostViewController:(NSString *) title content:(NSString *) content 
                  attachmentArray:(NSMutableArray *) attachmentArray
                       categoryID:(NSString *) categoryID categoryName:(NSString *) categoryName 
{
    NewPostViewController *newPostViewController = [[NewPostViewController alloc] init];
    newPostViewController.postTitle = title;
    newPostViewController.content = content;
    newPostViewController.tableData = attachmentArray;
    newPostViewController.selectedCategoryID = categoryID;
    newPostViewController.selectedCategoryName = categoryName;
    newPostViewController.boardName = boardName;
    
    UINavigationController *newPostNavViewController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    [newPostViewController release];
    
    [[self navigationController] presentModalViewController:newPostNavViewController animated:YES];
    [newPostNavViewController release];
}

-(void) modifyPost:(NSNotification *)notification
{
    @try {
        NSMutableDictionary *reqDict = (NSMutableDictionary *) notification.object;
        [reqDict setValue:postID forKey:@"bID"];
        [reqDict setValue:boardName forKey:@"boardName"];
        [[TransactionManager sharedManager] modifyBoardContent:reqDict];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == 1 )
    {
        NSString *jsCommand = @"document.fm1.userID.value;";            
        NSString *authorID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
        jsCommand = @"document.fm1.fileCount.value;";
        NSString *fileCount = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
        NSMutableArray *attahmentArray = [[NSMutableArray alloc] init];
        
        for ( int i = 0; i < [fileCount intValue]; i++ )
        {
            jsCommand = [NSString stringWithFormat:@"document.fm1.file%d.value;", i];
            NSString *file = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file]]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            jsCommand = [NSString stringWithFormat:@"document.fm1.file%d_ID.value;", i];
            NSString *fileID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            [dict setValue:fileID forKey:@"ID"];
            [dict setValue:image forKey:@"IMAGE"];
            [dict setValue:@"IMAGE" forKey:@"TYPE"];
            [dict setValue:file forKey:@"URL"];
            [attahmentArray addObject:dict];
            [dict release];
        }
        
        jsCommand = @"document.fm1.bodyTextOrder.value;";
        NSString *bodyTextOrder = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        jsCommand = @"document.fm1.bodyTextID.value;";
        NSString *bodyTextID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"BODYTEXT" forKey:@"content"];
        [dict setValue:@"TEXT" forKey:@"TYPE"];
        [dict setValue:bodyTextID forKey:@"ID"];
        [dict setValue:bodyTextOrder forKey:@"VERTICAL_ORDER"];
        
        if ( [attahmentArray count] != 0 && [attahmentArray count] >= [bodyTextOrder intValue] )
            [attahmentArray insertObject:dict atIndex:[bodyTextOrder intValue]];
        else {
            [attahmentArray insertObject:dict atIndex:0];
        }
        [dict release];
        
        jsCommand = @"document.fm1.categoryID.value;";
        NSString *categoryID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        jsCommand = @"document.fm1.categoryName.value;";
        NSString *categoryName = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
        if ( buttonIndex == 0 )
        {
            if ( [authorID isEqualToString:[[DataManager sharedDataManager] getMetaInfo:@"USER_ID"].value] == NO )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"본인이 작성한 내용만 삭제하실수 있습니다." 
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                [alert autorelease];
                return;
            }
            
            [self deleteContent];
        }
        else if ( buttonIndex == 1 )
        {
            if ( [authorID isEqualToString:[[DataManager sharedDataManager] getMetaInfo:@"USER_ID"].value] == NO )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"본인이 작성한 내용만 수정하실수 있습니다." 
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                [alert autorelease];
                return;
            }
            
            NSString *jsCommand = @"document.fm1.title.value;";            
            NSString *title = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            jsCommand = @"document.fm1.content.value;";            
            NSString *content = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            [self showNewPostViewController:title content:content attachmentArray:attahmentArray
                                 categoryID:categoryID categoryName:categoryName];
            [attahmentArray release];
        }
    }
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
    
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
          :UIActivityIndicatorViewStyleGray];
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
        
        if ( [@"SendMessage" isEqualToString:[[request.URL absoluteString] lastPathComponent]] )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *jsCommand = @"document.fm1.userIDToSendMessage.value;";            
            NSString *receiverID = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            if ( [[[DataManager sharedDataManager] metaInfoString:@"USER_ID"] isEqualToString:receiverID] )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"본인에게는 메세지를 전송할 수 없습니다." 
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                [alert autorelease];
                return NO;
            }
            
            jsCommand = @"document.fm1.nickNameToSendMessage.value;";
            NSString *nickName = [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
            SendMessageViewController *sendMessageViewController = [[SendMessageViewController alloc] init];
            sendMessageViewController.receiverID = receiverID;
            sendMessageViewController.receiverNickname = nickName;
            UINavigationController *sendMessageNavViewController = 
            [[UINavigationController alloc] initWithRootViewController:sendMessageViewController];
            [sendMessageViewController release];
            
            [[self navigationController] presentModalViewController:sendMessageNavViewController animated:YES];
            [sendMessageNavViewController release];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
    // Additional Code
}

-(void) submit:(NSString *) text
{
    if ( [boardWebView isLoading] )
    {
        [self performSelector:@selector(submit:) withObject:text afterDelay:0.5];
        return;
    }
    
    NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
    [reqDict setValue:postID forKey:@"bID"];
    [reqDict setValue:text forKey:@"content"];
    //    [[TransactionManager sharedManager] addReply:reqDict];
    
    NSString *jsCommand = [NSString stringWithFormat:@"addComment('%@', '%@', '%@', '%@');", postID, 
                           [text stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"] ,
                           [[DataManager sharedDataManager] metaInfoString:@"USER_ID"],
                           [[DataManager sharedDataManager] metaInfoString:@"NICKNAME"]];
    
    [boardWebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
    NSLog(@"%@", text );
}

- (void) sendButtonClicked
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    if ( [[commentField.text stringByTrimmingCharactersInSet:
           [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"댓글을 입력해 주십시오." 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    [self submit:commentField.text];
    commentField.text = @"";
    [commentField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    @try {
        
        if ( [theTextField returnKeyType] == UIReturnKeySend )
        {
            [self sendButtonClicked];
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
        
        NSTimeInterval animationDuration = 0.3;
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

-(void) loginSucceeded:(NSNotification *)notification
{
    NSString *urlString = Constants.boardContentURL;
    NSString *body = [NSString stringWithFormat: @"postID=%@&udid=%@&userID=%@&nickName=%@&boardName=%@", 
                      self.postID, [[[UIDevice currentDevice] identifierForVendor] UUIDString] , 
                      [[DataManager sharedDataManager] metaInfoString:@"USER_ID"],
                      [[DataManager sharedDataManager] metaInfoString:@"NICKNAME"], boardName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [boardWebView  loadRequest:request];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.subject = nil;
    self.postID = nil;
    self.userID = nil;
    self.boardName = nil;
    self.boardWebView = nil;
}

- (void)dealloc
{
    [boardWebView release];
    [subject release];
    [postID release];
    [userID release];
    [boardName release];
    [activeField release];
    [commentView release];
    [commentField release];
    [super dealloc];
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

