//
//  KoreanSGAppDelegate.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KoreanSGAppDelegate.h"
#import "KoreanShopListController.h"
#import "SettingsViewController.h"
#import "common.h"
#import "MetaInfo.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation KoreanSGAppDelegate

@synthesize window=_window;
@synthesize rootController, homeNavViewController, koreanShopNavViewController, queue;

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
//	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotificationReceived" object:userInfo];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ( self.queue == nil )
    {
        NSOperationQueue *q = [[NSOperationQueue alloc] init];
        self.queue = q;
        [q release];
    }
    
    [[TransactionManager sharedManager] getMetaInfoFromServer];
    
    homeViewController = [[HomeViewController alloc] init];
    homeNavViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [homeViewController release];
    
    [self.window addSubview:homeNavViewController.view];
    
    [self.window makeKeyAndVisible];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"becomeForeground" object:nil];
    [[TransactionManager sharedManager] getMetaInfoFromServer];    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = 
        [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[DataManager sharedDataManager] setMetaInfo:@"USER_DEVICE_TOKEN" value:token];
    
	NSLog(@"My token is: %@", token);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
    return [FBSession.activeSession handleOpenURL:url]; 
}

- (void)sessionStateChanged:(FBSession *)session 
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // FBSample logic
            // Once the user has logged in, we want them to be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification 
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"에러"
                                                            message:@"Facebook 로그인중 오류가 발생했습니다."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI 
{
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", nil];
    return [FBSession openActiveSessionWithPermissions:permissions
                                          allowLoginUI:allowLoginUI
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         [self sessionStateChanged:session state:state error:error];
                                     }];    
}

- (void)dealloc
{
    [koreanShopNavViewController release];
    [_window release];
    [queue release];
    [super dealloc];
}

@end
