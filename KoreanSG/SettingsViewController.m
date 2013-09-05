//
//  SettingsViewController.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "LoginInfoViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self setTitle:@"설정"];
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
    titleLabel2.text = @"Back";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel2];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        myTableView.frame = CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y,
                                       myTableView.frame.size.width, myTableView.frame.size.height + 90 );
    }
    
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    [myTableView release];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginSucceeded:) name:@"LoginSucceeded" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ( section == 0 )
        return 2;
    else if ( section == 1 )
    {
        return 1;
    }
    else {
        return 5;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if ( indexPath.section != 0 )
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
	
	if ( indexPath.section == 0 )
    {
        if ( indexPath.row == 0 )
            cell.textLabel.text = @"로그인 정보";
        else {
            cell.textLabel.text = @"어플 정보";
        }
    }
    else if (indexPath.section == 1 )
    {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blueColor];
        
        if ( [self isAlreadyLogin] )
            cell.textLabel.text = @"로그아웃";
        else {
            cell.textLabel.text = @"로그인";
        }
    }
    else {
        
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blueColor];
        
        if ( indexPath.row == 0 )
            cell.textLabel.text = @"업체정보수정요청";
        else if ( indexPath.row == 1 )
            cell.textLabel.text = @"업체신규등록요청";
        else if ( indexPath.row == 2 )
            cell.textLabel.text = @"업체메뉴등록요청";
        else if ( indexPath.row == 3 )
            cell.textLabel.text = @"버그보고";
        else if ( indexPath.row == 4 )
            cell.textLabel.text = @"기타 건의";
        
    }
    
    return cell;
}

- (void) loginSucceeded:(NSNotification *) notification
{
    [myTableView reloadData];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    //	NSUInteger fromRow = [fromIndexPath row];
    //    NSUInteger toRow = [toIndexPath row];
    
    
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	if ( indexPath.section == 0 )
    {
        if ( indexPath.row == 0 )
        {
            LoginInfoViewController *loginInfoViewController = [[LoginInfoViewController alloc] init];
            [self.navigationController pushViewController:loginInfoViewController animated:YES];
            [loginInfoViewController release];
        }
        else {
            AboutViewController *aboutViewController = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:aboutViewController animated:YES];
            [aboutViewController release];
        }
    }
    else if ( indexPath.section == 1 )
    {
        if ( [self isAlreadyLogin] )
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [[TransactionManager sharedManager] logout:nil];
            
            [[DataManager sharedDataManager] setMetaInfo:@"PASSWORD" value:@""];
            [[DataManager sharedDataManager] setMetaInfo:@"NICKNAME" value:@""];
            [[DataManager sharedDataManager] setMetaInfo:@"EMAIL" value:@""];
            [[DataManager sharedDataManager] setMetaInfo:@"LAST_LOGIN_TIME" value:@""];
            [[DataManager sharedDataManager] setMetaInfo:@"USER_NO" value:@""];
            [[DataManager sharedDataManager] setMetaInfo:@"USER_ID" value:@""];
            
            [tableView reloadData];
        }
        else {
            [self showModalLoginViewController];
        }
    }
    else if ( indexPath.section == 2 && indexPath.row != 2 )
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSString *body = @"";
        
        if ( indexPath.row != 3 && indexPath.row != 4)
        {
            body = [[NSString stringWithFormat:@"업체이름:\r\n업체종류[식당/학원/병원/컨설팅/미용/기타]:\r\nMobile No:\
                     \r\nTel:\r\n주소:\r\nEmail:\r\nHomepage:"] 
                    stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *url = [NSString stringWithFormat:@"mailto:hanintownsg@gmail.com?cc=&subject=[%@]&body=%@", 
                         [cell.textLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         body];
        
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
    else if ( indexPath.section == 2 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"메뉴판 사진을 hanintownsg@gmail.com 로\
                              보내주시기 바랍니다." message:nil 
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		[alert autorelease];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
}


- (void)dealloc {
    [super dealloc];
}

@end

