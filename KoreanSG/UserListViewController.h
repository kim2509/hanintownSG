//
//  UserListViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "common.h"

@interface UserListViewController : DYViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UITableView *myTableView;
    NSMutableArray *originalTableData;
    NSMutableArray *tableData;
    NSArray *index;
    UISearchBar* searchBar;
    BOOL bSearching;
}

@property(nonatomic, retain) NSMutableArray *tableData;
@property(nonatomic, retain) NSMutableArray *originalTableData;

@end
