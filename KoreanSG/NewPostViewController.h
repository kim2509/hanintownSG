//
//  NewPostViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface NewPostViewController : DYViewController<UITextViewDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
    UITextField *postTitleField;
    UITextView *inputTextView;
    NSString *postTitle;
    NSString *content;
    UIView *customToolBar;
    UIView *optionView;
    NSMutableArray *tableData;
    UILabel *categoryLabel;
    UIView *pictureInfoView;
    UILabel *pictureNumberLabel;
    UITableView *picturesTableView;
    NSMutableDictionary *modifyInfoDict;
    
    NSString *boardName;
    
    NSString *selectedCategoryID;
    NSString *selectedCategoryName;
}

@property(nonatomic, retain) UITextView *inputTextView;
@property(nonatomic, retain) NSString *postTitle;
@property(nonatomic, retain) NSString *content;
@property(nonatomic, retain) NSMutableArray *tableData;
@property(nonatomic, retain) NSString *boardName;
@property(nonatomic, retain) NSString *selectedCategoryID;
@property(nonatomic, retain) NSString *selectedCategoryName;

@end
