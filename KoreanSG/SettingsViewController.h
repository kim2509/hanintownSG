//
//  SettingsViewController.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"


@interface SettingsViewController : DYViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
}

@end