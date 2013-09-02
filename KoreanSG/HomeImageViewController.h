//
//  HomeImageViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 13/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface HomeImageViewController : DYViewController<SDWebImageManagerDelegate>
{
    UIButton *imageButton;
    NSString *imageURL;
    
    NSString *boardName;
    NSString *subject;
    NSString *userID;
    NSString *bID;
}

@property(nonatomic, retain) NSString *imageURL;
@property(nonatomic, retain) NSString *boardName;
@property(nonatomic, retain) NSString *subject;
@property(nonatomic, retain) NSString *userID;
@property(nonatomic, retain) NSString *bID;

- (void) reloadImage;

@end
