//
//  KoreanSGAppDelegate.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface KoreanSGAppDelegate : NSObject <UIApplicationDelegate> {

    UITabBarController *rootController;
    
    UINavigationController* homeNavViewController;
    UINavigationController* koreanShopNavViewController;
    
    NSMutableData *responseData;
    
    int showPriceVersion;
    
    NSOperationQueue *queue;
    
    HomeViewController *homeViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet UINavigationController* homeNavViewController;
@property (nonatomic, retain) IBOutlet UINavigationController* koreanShopNavViewController;
@property (nonatomic, retain) NSOperationQueue *queue;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI ;

@end
