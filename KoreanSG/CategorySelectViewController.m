//
//  CategorySelectViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategorySelectViewController.h"


@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation CategorySelectViewController

@synthesize checkedIndexPath, boardName, bShowAllCategory, callFrom, categoryID, tableData;

-(void) viewDidLoad
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 440) style:UITableViewStyleGrouped];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    [self.view addSubview:myTableView];
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
        
    self.title = @"분류 선택";
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *cancelButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    cancelButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [cancelButtonCustom addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"취소";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [cancelButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonCustom];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
}

- (void)setTitle:(NSString *)title
{    
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = [UIColor colorWithHexString:@"#141414"];
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

-(void) cancel
{
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self loadBoardCategory];
}

-(void) loadBoardCategory
{
    @try {
        
        self.tableData = [DYViewController getBoardCategoryList:boardName showOptional:bShowAllCategory];
        
        NSString *selectedCategoryID = @"";
        
        if ( [callFrom isEqualToString:@"newPost"] )
        {
            selectedCategoryID = categoryID;
        }
        else if ( [callFrom isEqualToString:@"listView"] )
        {
            selectedCategoryID = [[DataManager sharedDataManager] metaInfoString:
                                  [NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]];
        }
        
        for ( int i = 0; i < [tableData count]; i++ )
        {
            if ( selectedCategoryID == nil || [selectedCategoryID isEqualToString:@""] )
            {
                if ( [callFrom isEqualToString:@"newPost"] == NO )
                {
                    selectedCategoryID = [[tableData objectAtIndex:i] objectForKey:@"ID"];
                    
                    [[DataManager sharedDataManager] 
                     setMetaInfo:[NSString stringWithFormat:@"%@_CATEGORY_ID", boardName] 
                     value:selectedCategoryID];
                    self.checkedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    break;
                }
            }
            
            NSString *cID = [[tableData objectAtIndex:i] objectForKey:@"ID"];
            if ( [cID isEqualToString:selectedCategoryID] )
            {
                self.checkedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
        
        [myTableView reloadData];
        
    }
    @catch (NSException *exception) {
        NSLog(@"[loadBoardCategory exception]: %@", exception);
    }
    @finally {
        
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"분류를 선택해 주십시오.";
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if([self.checkedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSMutableDictionary *dict = [tableData objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [dict objectForKey:@"CATEGORY_NAME"];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    NSDictionary *dict = [tableData objectAtIndex:indexPath.row];
    
    if ( [callFrom isEqualToString:@"listView"] )
    {
        [[DataManager sharedDataManager] setMetaInfo:
         [NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]
                                               value:[dict objectForKey:@"ID"]];
        [[DataManager sharedDataManager] setMetaInfo:
         [NSString stringWithFormat:@"%@_CATEGORY_NAME", boardName]
                                               value:[dict objectForKey:@"CATEGORY_NAME"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryChanged" object:nil];
    }
    else if ( [callFrom isEqualToString:@"newPost"] )
    {
        NSMutableDictionary *categoryDict = [[[NSMutableDictionary alloc] init] autorelease];
        [categoryDict setValue:[dict valueForKey:@"ID"] forKey:@"SELECTED_CATEGORY_ID"];
        [categoryDict setValue:[dict valueForKey:@"CATEGORY_NAME"] forKey:@"SELECTED_CATEGORY_NAME"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCategory" object:categoryDict];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void) viewDidUnload
{
    self.boardName = nil;
    self.checkedIndexPath = nil;
    self.callFrom = nil;
    self.categoryID = nil;
}

- (void)dealloc
{
    [myTableView release];
//    [tableData release];
    [checkedIndexPath release];
    [boardName release];
    [callFrom release];
    [categoryID release];
    [super dealloc];
}
@end
