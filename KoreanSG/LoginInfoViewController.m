//
//  LoginInfoViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 27/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginInfoViewController.h"

@interface LoginInfoViewController ()

@end

@implementation LoginInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"로그인 정보"];
    
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
    
    
    UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    [myTableView release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ( section == 0 )
        return 2;
    else return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
    if ( indexPath.row == 0 )
    {
        cell.textLabel.text = @"사용자 아이디";
        cell.detailTextLabel.text = [[DataManager sharedDataManager] metaInfoString:@"USER_ID"];
    }
    else 
    {
        cell.textLabel.text = @"닉네임";
        cell.detailTextLabel.text = [[DataManager sharedDataManager] metaInfoString:@"NICKNAME"];
    }    
    return cell;
}

@end