//
//  HomeViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 14/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "KoreanShopListController.h"
#import "SettingsViewController.h"
#import "MessageListViewController.h"
#import "BoardHomeViewController.h"
#import "BoardItemListViewController.h"
#import "HomeImageViewController.h"
#import "BoardItemContentViewController.h"
#import "CustomBadge.h"

static NSUInteger kNumberOfPages = 5;

@interface HomeViewController ()

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

@implementation HomeViewController

@synthesize selectedIndexPath;

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
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    scrollView.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 130, 320, 20)];
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:pageControl];

    controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    tableData = [[NSMutableArray alloc] init];
    
//    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 160, 320, 256)];
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
    
    NSMutableDictionary *dict = nil;
    
    for ( int i = 0;i < 2; i++ )
    {
        dict = [[NSMutableDictionary alloc] init];
 
        if ( i == 0 )
            [dict setValue:@"업체목록" forKey:@"MENU_NAME"];
        else if ( i == 1 )
            [dict setValue:@"설정" forKey:@"MENU_NAME"];
        
        [tableData addObject:dict];
        
        [dict release];
    }
        
    [myTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mainInfoSent:) name:@"GetMainInfoSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mainInfoReceived:) name:@"GetMainInfoReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(imageViewTouched:) name:@"ImageViewTouched" object:nil];
    
}

-(void) mainInfoSent:(NSNotification *) notification
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

-(void) mainInfoReceived:(NSNotification *) notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            imageList = [[notification.object objectForKey:@"resultBody"] objectForKey:@"mainImageList"];
            
            if ( [imageList count] < 1 ) 
            {
                if ( retryCount == 0 )
                {
                    [[TransactionManager sharedManager] getMainInfo];
                    retryCount++;
                }
                
                return;
            }
            
            imageList = [imageList objectAtIndex:0];
            
            if ( [imageList count] < 1 ) 
            {
                if ( retryCount == 0 )
                {
                    [[TransactionManager sharedManager] getMainInfo];
                    retryCount++;
                }
                
                return;
            }
            
            [self loadScrollViewWithPage:0];
            [self loadScrollViewWithPage:1];
            
            NSMutableArray *notificationList = [[notification.object objectForKey:@"resultBody"] objectForKey:@"notificationList"];
            
            int nUnreadCount = 0;
            
            for ( int i = 0; i < [notificationList count]; i++ )
            {
                NSDictionary *dict = [notificationList objectAtIndex:i];
                if ( [@"N" isEqualToString:[dict valueForKey:@"IS_READ"]] )
                {
                    nUnreadCount++;
                }
            }
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nUnreadCount];
            
            
            tableData = [[notification.object objectForKey:@"resultBody"] objectForKey:@"serviceList"];
            tableData = [tableData objectAtIndex:0];
            [myTableView reloadData];
            
            boardCategoryList = [[notification.object objectForKey:@"resultBody"] objectForKey:@"boardCategoryList"];
            boardCategoryList = [boardCategoryList objectAtIndex:0];
            [DYViewController setBoardCategoryList:boardCategoryList];
        }  
    }
    @catch (NSException *exception) {
        NSLog(@"[httpRequestReceived exception]: %@", exception);
    }
    @finally {
        
    }
}

-(void) imageViewTouched:(NSNotification *) notification
{
    NSDictionary *dict = notification.object;
    
    BoardItemContentViewController *boardItemContentViewController = [[BoardItemContentViewController alloc] init];
    boardItemContentViewController.subject = [dict objectForKey:@"subject"];
    boardItemContentViewController.postID = [dict objectForKey:@"postID"];
    boardItemContentViewController.boardName = [dict objectForKey:@"boardName"];
    boardItemContentViewController.userID = [dict objectForKey:@"userID"];
    [self.navigationController pushViewController:boardItemContentViewController animated:YES];
    [boardItemContentViewController release];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setTitle:@"한인타운SG"];

    [myTableView reloadData];
    
    retryCount = 0;
    
    [[TransactionManager sharedManager] getMainInfo];
    
    if ( selectedIndexPath != nil )
        [myTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) appBecomeForeground:(NSNotification *) notification
{
    [super appBecomeForeground:notification];
    
    [myTableView reloadData];
    [[TransactionManager sharedManager] getMainInfo];
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
        return 150;
    
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
            [cell.contentView addSubview:pageControl];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if ( indexPath.row > 0 && indexPath.row <= [tableData count] )
    {
        NSMutableDictionary *dict = [tableData objectAtIndex:[indexPath row] - 1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict valueForKey:@"MENU_NAME"],
                               [dict valueForKey:@"ITEM_COUNT"]];
        
        if ( [dict valueForKey:@"ITEM_COUNT"] == nil || [dict valueForKey:@"ITEM_COUNT"] == [NSNull null] ||
            [@"" isEqualToString:[dict valueForKey:@"ITEM_COUNT"]])
            cell.textLabel.text = [dict valueForKey:@"MENU_NAME"];
        
        if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"업체목록"] )
            cell.imageView.image = [UIImage imageNamed:@"company.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"게시판"] )
            cell.imageView.image = [UIImage imageNamed:@"board.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"룸렌탈"] )
            cell.imageView.image = [UIImage imageNamed:@"room.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"벼룩시장"] )
            cell.imageView.image = [UIImage imageNamed:@"market.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"취업"] )
            cell.imageView.image = [UIImage imageNamed:@"job.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"쪽지함"] )
            cell.imageView.image = [UIImage imageNamed:@"message.png"];
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"알림센터"] )
        {
            cell.imageView.image = [UIImage imageNamed:@"notification.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if ( [[UIApplication sharedApplication] applicationIconBadgeNumber] > 0 )
            {
                CustomBadge *customBadge1 = [CustomBadge customBadgeWithString:
                                             [NSString stringWithFormat:@"%d", [[UIApplication sharedApplication] applicationIconBadgeNumber]] 
                                                               withStringColor:[UIColor whiteColor] 
                                                                withInsetColor:[UIColor redColor] 
                                                                withBadgeFrame:YES 
                                                           withBadgeFrameColor:[UIColor whiteColor] 
                                                                     withScale:1.0
                                                                   withShining:YES];
                
                customBadge1.frame = CGRectMake( 105 , 
                                                0, customBadge1.frame.size.width, customBadge1.frame.size.height);
                
                customBadge1.tag = 1;
                [cell.contentView addSubview:customBadge1];
            }
            else {
                if ( [cell.contentView viewWithTag:1] != nil )
                {
                    CustomBadge *customBadge1 = (CustomBadge *) [cell.contentView viewWithTag:1];
                    [customBadge1 removeFromSuperview];
                }
                
            }
        }
        else if ( [[dict valueForKey:@"MENU_NAME"] isEqualToString:@"설정"] )
            cell.imageView.image = [UIImage imageNamed:@"setting.png"];
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
    NSMutableDictionary *dict = [tableData objectAtIndex:[indexPath row] - 1];
    NSString *menuName = [dict objectForKey:@"MENU_NAME"];
    
    self.selectedIndexPath = indexPath;
    
    if ( [@"업체목록" isEqualToString:menuName] )
    {
        KoreanShopListViewController *koreanShopListViewController = [[KoreanShopListViewController alloc] init];
        [self.navigationController pushViewController:koreanShopListViewController animated:YES];
        [koreanShopListViewController release];
    }
    else if ( [@"설정" isEqualToString:menuName] )
    {
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:settingsViewController animated:YES];
        [settingsViewController release];
    }
    else if ( [@"게시판" isEqualToString:menuName] )
    {
        BoardHomeViewController *boardHomeViewController = [[BoardHomeViewController alloc] init];
        boardHomeViewController.boardCategoryList = boardCategoryList;
        [self.navigationController pushViewController:boardHomeViewController animated:YES];
        [boardHomeViewController release];
    }
    else if ( [@"쪽지함" isEqualToString:menuName] )
    {
        if ( [self isAlreadyLogin] == NO )
        {
            [self showModalLoginViewController];
            return;
        }
        
        MessageListViewController *messageListViewController = [[MessageListViewController alloc] init];
        [self.navigationController pushViewController:messageListViewController animated:YES];
        [messageListViewController release];
    }
    else if ( [@"알림센터" isEqualToString:menuName] )
    {
        if ( [self isAlreadyLogin] == NO )
        {
            [self showModalLoginViewController];
            return;
        }
        
        [self showNotificationViewController:YES];
    }
    else {
        BoardItemListViewController *boardItemListViewController = [[BoardItemListViewController alloc] init];
        boardItemListViewController.boardName = [dict objectForKey:@"BOARD_NAME"];
        boardItemListViewController.menuName = menuName;
        [self.navigationController pushViewController:boardItemListViewController animated:YES];
        [boardItemListViewController release];
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

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    HomeImageViewController *controller = [controllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[HomeImageViewController alloc] init];
        [controllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    if ( imageList != nil && [imageList count] > page )
    {
        NSDictionary *dict = [imageList objectAtIndex:page];
        controller.imageURL = [NSString stringWithFormat:@"%@%@mobile/%@", ServerUrl,
                               [dict objectForKey:@"PATH"], [dict objectForKey:@"FILE_NAME"]];
        
        controller.boardName = [dict objectForKey:@"BOARD_NAME"];
        controller.subject = [dict objectForKey:@"B_SUBJECT"];
        controller.bID = [dict objectForKey:@"B_ID"];
        controller.userID = [dict objectForKey:@"USER_ID"];
    }
    
    [controller reloadImage];
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)changePage:(id)sender
{
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

@end
