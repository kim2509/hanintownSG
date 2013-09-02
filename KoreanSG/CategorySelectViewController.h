//
//  CategorySelectViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "common.h"

@interface CategorySelectViewController : DYViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *tableData;
    NSIndexPath *checkedIndexPath;
    NSString *boardName;
    BOOL bShowAllCategory;
    NSString *callFrom;
    NSString *categoryID;
}

@property(nonatomic) BOOL bShowAllCategory;
@property(nonatomic, retain) NSString *boardName;
@property(nonatomic, retain) NSIndexPath *checkedIndexPath;
@property(nonatomic, retain) NSString *callFrom;
@property(nonatomic, retain) NSString *categoryID;
@property(nonatomic, retain) NSMutableArray *tableData;
@end
