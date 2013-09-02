//
//  ShopCell2.h
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "DataModel.h"

@interface ShopCell2 : UITableViewCell <SDWebImageManagerDelegate>
{
    Shop *shop;
    UIButton *imageButton;
}

@property(nonatomic, retain) Shop *shop;

- (void) setData:(Shop *) s;

@end
