//
//  BoardHomeViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "common.h"

@interface BoardHomeViewController : DYViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *tableData;
    NSIndexPath *selectedIndexPath;
    
    UIScrollView *scrollView;
    
    NSMutableArray *imageList;
    NSMutableArray *imgViewControllers;
    
    NSMutableArray *boardCategoryList;
    
    int retryCount;
}

@property(nonatomic,retain) NSIndexPath* selectedIndexPath;
@property(nonatomic,retain) NSMutableArray *boardCategoryList;

@end
