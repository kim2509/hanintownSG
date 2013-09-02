//
//  MenuCell3.h
//  KoreanSG
//
//  Created by Daeyong Kim on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface MenuCell3 : UITableViewCell
{
    Menu *menu;
}

@property(nonatomic, retain) Menu *menu;

-(void) setData:(Menu *)menu shop:(Shop *)shop bNeverShowPrice:(BOOL) bNeverShowPrice;

@end
