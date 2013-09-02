//
//  CategoryViewController.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryViewDelegate.h"

@interface CategoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
 
    UITableView *myTableView;
    id <CategoryViewDelegate> delegate;
    NSMutableArray *categoryList;
}

@property (nonatomic, retain) NSMutableArray *categoryList;
@property (nonatomic, assign) id <CategoryViewDelegate> delegate;

- (void) closeWindow;

@end
