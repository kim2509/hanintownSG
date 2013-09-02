//
//  LoginViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 23/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterMemberViewController.h"
#import "LoginInputViewController.h"
#import "KoreanSGAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()

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

@implementation LoginViewController

@synthesize selectedIndexPath;

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
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    [myTableView release];
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    self.title = @"계정";
    
    
    informLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 320, 25)];
    informLabel.textAlignment = UITextAlignmentCenter;
    informLabel.backgroundColor = [UIColor clearColor];
    informLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:informLabel];
    [informLabel release];
    
    informLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 265, 320, 25)];
    informLabel2.textAlignment = UITextAlignmentCenter;
    informLabel2.backgroundColor = [UIColor clearColor];
    informLabel2.font = [UIFont systemFontOfSize:15];
    informLabel2.textColor = [UIColor redColor];
    [self.view addSubview:informLabel2];
    [informLabel2 release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didFacebookLogin:) 
                                                 name:SCSessionStateChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(facebookLoginSent:) name:@"facebookLoginSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(facebookLoginReceived:) name:@"facebookLoginReceived" object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    if ( selectedIndexPath != nil )
        [myTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
}

-(void) viewDidAppear:(BOOL)animated
{
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *cancelButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    cancelButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [cancelButtonCustom addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"취소";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [cancelButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonCustom];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
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

-(void) cancel
{
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.selectedIndexPath = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section == 0 )
        return @"이미 계정이 있을 경우";
    else {
        return @"계정을 새로 만들 경우";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ( section == 0 )
        return 2;
    else {
        return 1;
    }
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

    }
    
    if ( indexPath.section == 0 && indexPath.row == 0 )
    {
        cell.textLabel.text = @"로그인";
    }
    else if ( indexPath.section == 0 && indexPath.row == 1 )
    {
        cell.textLabel.text = @"페이스북 로그인";
    }
    else if ( indexPath.section == 1 )
    {
        cell.textLabel.text = @"회원가입";
    }
    else {
        
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //NSString *menuName = [tableData objectAtIndex:[indexPath row]];
    
    self.selectedIndexPath = indexPath;
    
    if ( indexPath.section == 0 && indexPath.row == 0 )
    {
        LoginInputViewController *loginInputViewController = [[LoginInputViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:loginInputViewController animated:YES];
        [loginInputViewController release];
    }
    else if ( indexPath.section == 0 && indexPath.row == 1 )
    {
        [self facebookLoginSent:nil];
        
        [myTableView deselectRowAtIndexPath:indexPath animated:YES];
        KoreanSGAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    else if ( indexPath.section == 1 )
    {
        RegisterMemberViewController *registerMemberViewController = [[RegisterMemberViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:registerMemberViewController animated:YES];
        [registerMemberViewController release];
    }
}

-(void) didFacebookLogin:(NSNotification *) notification
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 NSLog(@"id:%@ firstname:%@ facebookLink:%@", user.id , user.first_name, user.link );
                 
                 NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
                 
                 [reqDict setValue:user.id forKey:@"facebookID"];
                 [reqDict setValue:user.link forKey:@"facebookURL"];
                 [reqDict setValue:user.first_name forKey:@"nickName"];
                 [[TransactionManager sharedManager] login:reqDict];
             }
         }];   
    }
}

- (void) appBecomeForeground:(NSNotification *) notification
{
    [super appBecomeForeground:notification];
    
    
}

-(void) facebookLoginSent:(NSNotification *)notification
{
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
          :UIActivityIndicatorViewStyleGray];
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];
}

-(void) setUserData:(NSMutableDictionary *) resDict
{
    [[DataManager sharedDataManager] setMetaInfo:@"USER_ID" value:[resDict objectForKey:@"USER_ID"]];
    [[DataManager sharedDataManager] setMetaInfo:@"PASSWORD" value:[resDict objectForKey:@"PASSWORD"]];
    [[DataManager sharedDataManager] setMetaInfo:@"NICKNAME" value:[resDict objectForKey:@"NICKNAME"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_NO" value:[resDict objectForKey:@"USER_NO"]];
    [[DataManager sharedDataManager] setMetaInfo:@"EMAIL" value:[resDict objectForKey:@"EMAIL"]];
    [[DataManager sharedDataManager] setMetaInfo:@"LAST_LOGIN_TIME" value:[resDict objectForKey:@"LAST_LOGIN_TIME"]];
}

-(void) facebookLoginReceived:(NSNotification *)notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            resDict = [resDict objectForKey:@"resultBody"];
            informLabel.textColor = [UIColor blueColor];
            informLabel.text = [NSString stringWithFormat:@"어서오십시오. %@ 님.", [resDict objectForKey:@"NICKNAME"]];
            informLabel2.text = @"";
            [self setUserData:resDict];
            [self performSelector:@selector(afterHTTPReceived:) withObject:resDict afterDelay:0.5];
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

-(void) afterHTTPReceived:(NSMutableDictionary *) resDict
{
    [[DataManager sharedDataManager] setMetaInfo:@"NICKNAME" value:[resDict objectForKey:@"NICKNAME"]];
    [[DataManager sharedDataManager] setMetaInfo:@"EMAIL" value:[resDict objectForKey:@"EMAIL"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_ID" value:[resDict objectForKey:@"USER_ID"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_NO" value:[resDict objectForKey:@"USER_NO"]];
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceeded" object:nil];
}

-(void) dealloc
{
    [selectedIndexPath release];
    [super dealloc];
}

@end
