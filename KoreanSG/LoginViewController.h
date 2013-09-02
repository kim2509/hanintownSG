//
//  LoginViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 23/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface LoginViewController : DYViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
    NSIndexPath *selectedIndexPath;
    
    UILabel *informLabel;
    UILabel *informLabel2;
}

@property(nonatomic,retain) NSIndexPath* selectedIndexPath;

@end
