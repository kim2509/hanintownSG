//
//  MenuCell.h
//  KoreanSG
//
//  Created by Daeyong Kim on 17/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KoreanShopListController.h"

@interface MenuCell : UITableViewCell <SDWebImageManagerDelegate>
{
    Menu *menu;
    UIButton *imageButton;
    KoreanShopListViewController *parentController;
}

@property(nonatomic, retain) Menu *menu;
@property(nonatomic, retain) KoreanShopListViewController *parentController;

-(void) hideCommentsNLikes:(BOOL) bHide;
-(void) setData:(Menu *) menu bShowPrice:(BOOL) bNeverShowPrice;

@end
