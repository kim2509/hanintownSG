//
//  HomeViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 14/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface HomeViewController : DYViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *tableData;
    NSIndexPath *selectedIndexPath;
    
    UIPageControl *pageControl;
    
    NSMutableArray *controllers;
    
    UIScrollView *scrollView;
    
    BOOL pageControlUsed;
    
    NSMutableArray *imageList;
    
    int retryCount;
    
    NSMutableArray *boardCategoryList;
}

@property(nonatomic,retain) NSIndexPath* selectedIndexPath;

@end
