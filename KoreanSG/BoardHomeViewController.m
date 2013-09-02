//
//  BoardHomeViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoardHomeViewController.h"
#import "BoardItemListViewController.h"
#import "BoardImageViewController.h"

@interface BoardHomeViewController ()

@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation BoardHomeViewController

@synthesize selectedIndexPath, boardCategoryList;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
    scrollView.backgroundColor = [UIColor grayColor];
    
    imgViewControllers = [[NSMutableArray alloc] init];
    
    tableData = [[NSMutableArray alloc] init];
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    [myTableView release];
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    self.title = @"게시판";
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                            initWithFrame:CGRectMake(5, 0, 63, 32 )];
    titleLabel2.text = @"Home";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    [backButtonCustom addSubview:titleLabel2];
    [titleLabel2 release];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
    [myTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(boardMainInfoSent:) name:@"GetBoardMainInfoSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(boardMainInfoReceived:) name:@"GetBoardMainInfoReceived" object:nil];
    
    [[TransactionManager sharedManager] getBoardMainInfo];
}

- (void) goHome
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    if ( selectedIndexPath != nil )
        [myTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count] + 1;
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( indexPath.row == 0 )
        return 140;
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        if ( indexPath.row == 0 )
        {
            [cell.contentView addSubview:scrollView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 320, 20)];
            label.text = @"최신 글";
            label.font = [UIFont boldSystemFontOfSize:13];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
            [label release];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if ( indexPath.row > 0 && indexPath.row <= [tableData count] )
    {
        NSMutableDictionary *dict = [tableData objectAtIndex:[indexPath row]-1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict valueForKey:@"MENU_NAME"],
                               [dict valueForKey:@"ITEM_COUNT"]];
        
        if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"자유게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"free_board.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"질문/답변 게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"question.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"로컬정보공유 게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"singapore.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"번개게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"meet.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"여행게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"travel.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"사진갤러리"] )
            cell.imageView.image = [UIImage imageNamed:@"gallery.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"문의/건의 사항"] )
            cell.imageView.image = [UIImage imageNamed:@"idea.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"프로모션정보 게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"promotion.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"취업정보공유 게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"job.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"환전 게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"money_exchange.png"];
        else {
            cell.imageView.image = [UIImage imageNamed:@"icon_etc.png"];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSMutableDictionary *dict = [tableData objectAtIndex:[indexPath row]-1];
    NSString *menuName = [dict objectForKey:@"MENU_NAME"];
    
    self.selectedIndexPath = indexPath;
    
    BoardItemListViewController *boardItemListViewController = [[BoardItemListViewController alloc] init];
    boardItemListViewController.boardName = [dict objectForKey:@"BOARD_NAME"];
    boardItemListViewController.menuName = menuName;
    [self.navigationController pushViewController:boardItemListViewController animated:YES];
    [boardItemListViewController release];
}

-(void) boardMainInfoSent:(NSNotification *) notification
{
    if ( av == nil )
    {
        av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];    
}

-(void) boardMainInfoReceived:(NSNotification *) notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            imageList = [[notification.object objectForKey:@"resultBody"] objectForKey:@"imageList"];            
            imageList = [imageList objectAtIndex:0];
            
            tableData = [[notification.object objectForKey:@"resultBody"] objectForKey:@"serviceList"];
            
            if ( [tableData count] < 1 ) 
            {
                if ( retryCount == 0 )
                {
                    [[TransactionManager sharedManager] getBoardMainInfo];
                    retryCount++;
                }
                
                return;
            }
            
            tableData = [tableData objectAtIndex:0];
            [myTableView reloadData];

            scrollView.contentSize = CGSizeMake(125 * [imageList count] + 5, 80 );
            for ( int i = 0; i < [imageList count]; i++ )
            {
                NSDictionary *dict = [imageList objectAtIndex:i];
                BoardImageViewController *controller = [[BoardImageViewController alloc] init];
                controller.imgURL = [NSString stringWithFormat:@"%@%@mobile/%@", ServerUrl,
                                       [dict objectForKey:@"PATH"], [dict objectForKey:@"FILE_NAME"]];
                [imgViewControllers addObject:controller];
                
                controller.boardName = [dict objectForKey:@"BOARD_NAME"];
                controller.subject = [dict objectForKey:@"B_SUBJECT"];
                controller.bID = [dict objectForKey:@"B_ID"];
                controller.userID = [dict objectForKey:@"USER_ID"];
                
                controller.view.frame = CGRectMake( 125 * i + 5 , 20, 125, 80);
                [scrollView addSubview:controller.view];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[boardMainInfoReceived exception]: %@", exception);
    }
    @finally {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.    
    self.selectedIndexPath = nil;
}

-(void)dealloc
{
    [myTableView release];
    [tableData release];
    [selectedIndexPath release];
    [super dealloc];
}


@end
