//
//  DYViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DYViewController.h"
#import "SendMessageViewController.h"
#import "UserListViewController.h"
#import "LoginViewController.h"
#import "NotificationViewController.h"

@interface DYViewController ()

@end

static NSMutableArray *boardCategoryList;

@implementation DYViewController

@synthesize av;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appBecomeForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pushNotificationReceived:) name:@"PushNotificationReceived" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) openSendMessageViewController:(NSString *) userID nickName:(NSString *)nickName
{    
    SendMessageViewController *sendMessageViewController = [[SendMessageViewController alloc] init];
    sendMessageViewController.receiverID = userID;
    sendMessageViewController.receiverNickname = nickName;
    UINavigationController *sendMessageNavViewController = 
    [[UINavigationController alloc] initWithRootViewController:sendMessageViewController];
    [sendMessageViewController release];
    
    [[self navigationController] presentModalViewController:sendMessageNavViewController animated:YES];
    [sendMessageNavViewController release];
}

-(void) openUserListViewController
{    
    UserListViewController *userListViewController = [[UserListViewController alloc] init];
    UINavigationController *userListNavViewController = 
    [[UINavigationController alloc] initWithRootViewController:userListViewController];
    [userListViewController release];
    
    [[self navigationController] presentModalViewController:userListNavViewController animated:YES];
    [userListNavViewController release];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void) showModalLoginViewController
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *loginNavViewController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [loginViewController release];
    
    loginNavViewController.title = @"로그인";
    [[self navigationController] presentModalViewController:loginNavViewController animated:YES];
    [loginNavViewController release];
}

-(void) showNotificationViewController:(BOOL) animated
{
    NotificationViewController *notificationViewController = [[NotificationViewController alloc] init];
    UINavigationController *notificationNavViewController = [[UINavigationController alloc] initWithRootViewController:notificationViewController];
    [notificationViewController release];
    
    [[self navigationController] presentModalViewController:notificationNavViewController animated:animated];
    [notificationNavViewController release];
}

-(BOOL) isAlreadyLogin
{
    if ( [[[DataManager sharedDataManager] metaInfoString:@"NICKNAME"] isEqualToString:@""] )
        return NO;
    
    return YES;
}

- (void) appBecomeForeground:(NSNotification *) notification
{
    
}

- (void) pushNotificationReceived:(NSNotification *) notification
{
    [self showNotificationViewController:NO];
}

+ (void) setBoardCategoryList:(NSMutableArray *) list
{
    boardCategoryList = list;
}

+(NSMutableArray *) getBoardCategoryList:(NSString *) boardName showOptional:(BOOL) bShowOptional
{
    if ( boardCategoryList == nil ) return nil;
    
    NSString *showOptional = @"";
    
    if ( bShowOptional )
        showOptional = @"Y";
    else {
        showOptional = @"N";
    }
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for ( int i = 0; i < [boardCategoryList count]; i++ )
    {
        NSMutableDictionary *dict = [boardCategoryList objectAtIndex:i];
        
        if ( [boardName isEqualToString:[dict valueForKey:@"BOARD_NAME"]] &&
            [showOptional isEqualToString:@"Y"])
        {
            [list addObject:dict];
        }
        else if ( [boardName isEqualToString:[dict valueForKey:@"BOARD_NAME"]] &&
                 [@"N" isEqualToString:[dict valueForKey:@"IS_OPTIONAL"]])
        {
            [list addObject:dict];
        }
    }
    
    return list;
}

+(BOOL) isRetinaDisplay
{
    int height = [[UIScreen mainScreen] bounds].size.height;
    if ( height == 568 )
        return YES;
    else
        return NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.av = nil;
}

-(void) dealloc
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [av release];
    [super dealloc];
}

@end
