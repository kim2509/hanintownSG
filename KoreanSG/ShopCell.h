//
//  ShopCell.h
//  KoreanSG
//
//  Created by Daeyong Kim on 17/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "common.h"
#import "KoreanShopListController.h"

@interface ShopCell : UITableViewCell <SDWebImageManagerDelegate>
{
    Shop *shop;
    UIButton *imageButton;
    KoreanShopListViewController *parentController;
}

@property(nonatomic, retain) Shop *shop;
@property(nonatomic, retain) KoreanShopListViewController *parentController;

-(void) hideCommentsNLikes:(BOOL) bHide;
- (void) setData:(Shop *) s;

@end
