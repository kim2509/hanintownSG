//
//  MenuCell2.h
//  KoreanSG
//
//  Created by Daeyong Kim on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "DataModel.h"

@interface MenuCell2 : UITableViewCell <SDWebImageManagerDelegate>
{
    Menu *menu;
    UIButton *imageButton;
}

@property(nonatomic, retain) Menu *menu;

-(void) hideCommentsNLikes:(BOOL) bHide;
-(void) setData:(Menu *)menu shop:(Shop *)shop bNeverShowPrice:(BOOL) bNeverShowPrice;

@end
