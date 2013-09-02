//
//  UserLikesNCommentsViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "DataModel.h"

@interface UserLikesNCommentsViewController : DYViewController<UITableViewDelegate,UITableViewDataSource, UIAlertViewDelegate>
{
    UITableView *myTableView;
    
    NSObject *object;
    
    NSMutableArray *data;
    
    NSMutableArray *comments;
    
    UIBarButtonItem *likeButton;
    UIBarButtonItem *unLikeButton;
    
    int height;
    
    NSObject *tempObject;
}

@property(nonatomic, retain) NSObject *object;
@property(nonatomic, retain) NSObject *tempObject;
@property(nonatomic, retain) NSMutableArray *data;
@property(nonatomic, retain) NSMutableArray *comments;

-(void) loadLikes;

@end
