//
//  KoreanShopListController.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KoreanShopListController.h"
#import "KoreanShopDetailViewController.h"
#import "Shop.h"
#import "KoreanShopMapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CategoryViewController.h"
#import "MetaInfo.h"
#import "MenuGroup.h"
#import "Menu.h"
#import "MyToolBar.h"
#import "Cells.h"
#import "CommentInputViewController.h"
#import "UserLikesNCommentsViewController.h"

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation KoreanShopListViewController

@synthesize shopList, favoritesShopList, recentlyOpenedShopList, menuList,toolbar, tableData, dataManager, 
categorySelectButton, viewOptionButton, sortOptionButton,viewOptionImageView,sortOptionImageView,
currentLocation, searchBar, selectedIndexPath, mapButton, locationManager, tempShop, tempMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.dataManager = [DataManager sharedDataManager];
    
    tableData = [[NSMutableArray alloc] init];
	    
    [self addNavigationBarButtons];
    
    [self addTabButtons];
    
    if ( [DYViewController isRetinaDisplay])
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 42, 320, 421)];
    else
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 42, 320, 331)];
    
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    
    [self addSearchBarOnTableView];
    
    selectedTabIndex = 0;
    
    [self tabButton1Clicked:nil];
    
    [self configureLocation];
    
    self.tempShop = nil;
    
    [self setTitle:@"업체목록"];
}

-(void) addSearchBarOnTableView
{
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    searchBar.barStyle=UIBarStyleDefault;
    searchBar.showsCancelButton=NO;
    searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    searchBar.delegate = self;
    
    UIImageView* iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bg.png"]];
    iview.frame = CGRectMake(0, 0, 320, 44);
    [searchBar insertSubview:iview atIndex:1];
    [iview release];
    
    myTableView.tableHeaderView = searchBar;
    [searchBar release];
}

-(void) configureLocation
{
    CLLocationManager *clManager = [[CLLocationManager alloc] init];
    self.locationManager = clManager;
    [clManager release];
    locationManager.delegate = self;
    
    CLLocation *clocation = [[CLLocation alloc] init];
    self.currentLocation = clocation;
    [clocation release];
}

- (void) goHome
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) shopSelect:(Shop *) shop
{
    self.tempShop = nil;
    
    KoreanShopDetailViewController *detailViewController = 
    [[KoreanShopDetailViewController alloc] init];
    detailViewController.title = [shop shopName];
    detailViewController.shop = shop;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void) shopImageSelected:(Shop *) shop
{
    BOOL bGoDetail = NO;
    self.tempShop = shop;
    
    UIActionSheet *popupQuery = nil;
    
    if ( bGoDetail )
    {
        [self shopSelect:shop];
    }
    else
    {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"상세정보보기", @"사진업로드", nil];
    }
    
    popupQuery.tag = 3;
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
    [popupQuery release];
}

-(void) menuImageSelected:(Menu *) menu
{
    BOOL bGoDetail = NO;
    
    self.tempMenu = menu;
    
    UIActionSheet *popupQuery = nil;
    
    if ( bGoDetail )
    {
        [self menuSelect:menu];
    }
    else
    {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"상세정보보기", @"사진업로드", nil];
    }
    
    popupQuery.tag = 3;
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
    [popupQuery release];   
}

-(void) menuSelect:(Menu *) menu
{
    self.tempMenu = nil;
    
    Shop *shop = [[dataManager shopWithSeq:menu.shopSeq] retain];
    
    shop.menuList = [dataManager menuList:shop.seq];
    
    int menuIndex = 0;
    
    for ( int i = 0; i < [shop.menuList count]; i++ ) 
    {
        Menu *m = (Menu *) [shop.menuList objectAtIndex:i];
        if ( m.menuSeq == menu.menuSeq )
        {
            menuIndex = i;
            break;
        }
    }
    
    KoreanShopDetailViewController *detailViewController = 
    [[KoreanShopDetailViewController alloc] init];
    detailViewController.title = [shop shopName];
    detailViewController.shop = shop;
    detailViewController.scrollToMenuIndex = menuIndex;
    [shop release];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void) updateShop:(NSNotification *) notification
{
    [tableData removeAllObjects];
    [myTableView reloadData];
    
    if ( selectedTabIndex == 0 )
    {
        self.shopList = nil;
        
        [self updateShopList];
    }
    else if ( selectedTabIndex == 1 )
    {
        self.recentlyOpenedShopList = nil;
        
        [self updateNewShopList];
    }
    else if ( selectedTabIndex == 2 )
    {
        self.menuList = nil;
        
        [self updateMenuList];
    }
}

-(void) addLikesNComments:(NSNotification *)notification
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    if ( [notification.object isKindOfClass:[Shop class]] )
        self.tempShop = notification.object;
    else if ( [notification.object isKindOfClass:[Menu class]] )
        self.tempMenu = notification.object;
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"리뷰를 남기시겠습니까?\n(익명으로 남기게 됩니다.)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Like", @"Comment", nil];
    
    popupQuery.tag = 1;
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
    [popupQuery release];
}

-(void) viewLikesNComments:(NSNotification *)notfication
{
    UserLikesNCommentsViewController *userLikesNCommentsViewController = 
    [[UserLikesNCommentsViewController alloc] init];
    userLikesNCommentsViewController.object = notfication.object;
    
    [self.navigationController pushViewController:userLikesNCommentsViewController animated:YES];
    [userLikesNCommentsViewController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == 1 )
    {
        if ( buttonIndex == 0 )
        {
            if ( self.tempShop != nil )
            {
                ShopLike *shopLike = [[ShopLike alloc] init];
                shopLike.shopLikeNo = -1;
                shopLike.shopNo = self.tempShop.seq;
                shopLike.userNo = [[dataManager metaInfoString:@"USER_NO"] intValue];
                
                [[TransactionManager sharedManager] addShopLike:self.tempShop shoplike:shopLike];
                [shopLike release];
            }
            else if ( self.tempMenu != nil )
            {
                MenuLike *menuLike = [[MenuLike alloc] init];
                menuLike.menuLikeNo = -1;
                menuLike.menuNo = self.tempMenu.menuSeq;
                menuLike.userNo = [[dataManager metaInfoString:@"USER_NO"] intValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
                
                [[TransactionManager sharedManager] addMenuLike:self.tempMenu shoplike:menuLike];
                [menuLike release];
            }
            
            self.tempShop = nil;
            self.tempMenu = nil;
        }
        else if ( buttonIndex == 1 )
        {
            CommentInputViewController *commentInputViewController = [[CommentInputViewController alloc] init];
            
            UINavigationController *commentNavController = [[UINavigationController alloc] initWithRootViewController:commentInputViewController];
            [commentInputViewController release];
            
            commentNavController.title = @"Comment";
            
            [[self navigationController] presentModalViewController:commentNavController animated:NO];
            [commentNavController release];
        }   
    }
    else if ( actionSheet.tag == 2 )
    {
        UIImagePickerController* imagePickerController;
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        if ( buttonIndex == 0 )
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.navigationController presentModalViewController:imagePickerController animated:YES];
        }
        else if ( buttonIndex == 1 )
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.navigationController presentModalViewController:imagePickerController animated:YES];
        }
        else
        {
            self.tempShop = nil;
            self.tempMenu = nil;
        }
    }
    else if ( actionSheet.tag == 3 )
    {
        if ( buttonIndex == 0 )
        {
            if ( self.tempShop != nil )
                [self shopSelect:self.tempShop];
            else if ( self.tempMenu != nil )
                [self menuSelect:self.tempMenu];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopSelect" object:self.tempShop];
            return;
        }
        else if ( buttonIndex == 1 )
        {
            UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"사진을 업로드하시겠습니까?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo album", nil];
            
            popupQuery.tag = 2;
            popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
            [popupQuery showInView:self.view];
            [popupQuery release];   
        }
        else 
        {
            self.tempShop = nil;
            self.tempMenu = nil;
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    
    if ( image == nil )
        NSLog(@"nil");
    else
    {
        image = [self imageWithImage:image scaledToSize:CGSizeMake(158, 124)];
        NSData *data = UIImagePNGRepresentation(image);
        
        NSURL *url = nil;
        
        NSString *fileName = @"";
        
        if ( self.tempShop != nil )
        {
            url = [NSURL URLWithString:[Constants uploadShopImageURL]];
            fileName = [NSString stringWithFormat:@"S%d.png",self.tempShop.seq];
        }
        else if ( self.tempMenu != nil )
        {
            url = [NSURL URLWithString:[Constants uploadMenuImageURL]];
            fileName = [NSString stringWithFormat:@"M%d.png",self.tempMenu.menuSeq];
        }
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setData:data withFileName:fileName andContentType:@"image/png" forKey:@"uploadedfile"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(uploadRequestFinished:)];
        [request setDidFailSelector:@selector(uploadRequestFailed:)];
        [request startAsynchronous];
    }
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{    
    NSString *responseString = [request responseString];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:responseString message:nil 
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert autorelease];
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]); 
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error while uploading image." message:nil 
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert autorelease];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void) addComment:(NSNotification *)notification
{
    if ( self.tempShop != nil )
    {
        ShopComment *shopComment = [[ShopComment alloc] init];
        shopComment.shopCommentNo = -1;
        shopComment.shopNo = self.tempShop.seq;
        shopComment.userNo = [[dataManager metaInfoString:@"USER_NO"] intValue];
        shopComment.comment = notification.object;
        [[DataManager sharedDataManager] insertShopComment:shopComment];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
        [[TransactionManager sharedManager] addShopComment:self.tempShop shopComment:shopComment];
        [shopComment release];
    }
    else if ( self.tempMenu != nil )
    {
        MenuComment *menuComment = [[MenuComment alloc] init];
        menuComment.menuCommentNo = -1;
        menuComment.menuNo = self.tempMenu.menuSeq;
        menuComment.userNo = [[dataManager metaInfoString:@"USER_NO"] intValue];
        menuComment.comment = notification.object;
        [[DataManager sharedDataManager] insertMenuComment:menuComment];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
        [[TransactionManager sharedManager] addMenuComment:self.tempMenu shopComment:menuComment];
        [menuComment release];
    }
    
    self.tempShop = nil;
    self.tempMenu = nil;
}

-(void) showMessage:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.object message:nil 
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
}

- (void) addNavigationBarButtons
{
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
    titleLabel2.text = @"Home";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel2];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    mapButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    mapButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [mapButtonCustom addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"지도";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [mapButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    self.mapButton = [[UIBarButtonItem alloc] initWithCustomView:mapButtonCustom];
	[mapButton release];
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

- (void) addTabButtons 
{
    tabButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 87, 42)];
    [tabButton1 setImage:[UIImage imageNamed:@"tap_01_on.png"] forState:UIControlStateNormal];
    [self.view addSubview:tabButton1];
    [tabButton1 addTarget:self action:@selector(tabButton1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    tabButton2 = [[UIButton alloc] initWithFrame:CGRectMake(87, 0, 135, 42)];
    [tabButton2 setImage:[UIImage imageNamed:@"tap_02_off.png"] forState:UIControlStateNormal];
    [self.view addSubview:tabButton2];
    [tabButton2 addTarget:self action:@selector(tabButton2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    tabButton3 = [[UIButton alloc] initWithFrame:CGRectMake(222, 0, 98, 42)];
    [tabButton3 setImage:[UIImage imageNamed:@"tap_03_off.png"] forState:UIControlStateNormal];
    [self.view addSubview:tabButton3];
    [tabButton3 addTarget:self action:@selector(tabButton3Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) showMap
{
    KoreanShopMapViewController *mapViewController = [[KoreanShopMapViewController alloc] init];
    mapViewController.shopList = tableData;
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registerNotifications];
    
    MetaInfo *neverShowPriceInfo = [dataManager getMetaInfo:@"NEVER_SHOW_PRICE"];
    if ( neverShowPriceInfo != nil && neverShowPriceInfo.value != nil && [neverShowPriceInfo.value isEqualToString:@""] == NO )
    {
        bNeverShowPrice = [neverShowPriceInfo.value boolValue];
    }
    
    [self initToolBarItems];
    
    [myTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    
    MetaInfo *metaInfo = nil;
    
    if ( selectedTabIndex == 0 )
        metaInfo = [[DataManager sharedDataManager] getMetaInfo:@"TAB1_SORT_OPTION_BY"];
    else if ( selectedTabIndex == 1 )
        metaInfo = [[DataManager sharedDataManager] getMetaInfo:@"TAB2_SORT_OPTION_BY"];
    
    if ( metaInfo != nil && metaInfo.value != nil && [metaInfo.value isEqualToString:@""] == NO )
    {
        sortOption.selectedSegmentIndex = [[metaInfo value] intValue];
        
        if ( sortOption.selectedSegmentIndex == 0 )
        {
            sortOptionImageView.image = [UIImage imageNamed:@"B2_on.png"];
        }
        else
        {
            sortOptionImageView.image = [UIImage imageNamed:@"B2_on2.png"];
        }
    }
}

-(void) registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateShop:) name:@"UserLikesNCommentsUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addLikesNComments:) name:@"AddLikesNComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addComment:) name:@"AddComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(viewLikesNComments:) name:@"ViewLikesNComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showMessage:) name:@"ShowMessage" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [locationManager stopUpdatingLocation];
    [self.toolbar removeFromSuperview];
}

- (void) initToolBarItems
{
    self.toolbar = [[MyToolbar alloc] init];
    //self.toolbar = [[UIToolbar alloc] init];
    
	[self.toolbar release];
	self.toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
	[toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
	CGFloat toolbarHeight = [toolbar frame].size.height;
	
	//Get the bounds of the parent view
	CGRect rootViewBounds = self.parentViewController.view.bounds;
	
	//Get the height of the parent view.
	CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	
	//Get the width of the parent view,
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	
	//Create a rectangle for the toolbar
	CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight );
	
	//Reposition and resize the receiver
	[toolbar setFrame:rectArea];
    
    UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryButton.frame = CGRectMake(0, 0, 60, 35);
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_off"] forState:UIControlStateNormal];
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_on"] forState:UIControlStateSelected];
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_on"] forState:UIControlStateHighlighted];
    [categoryButton addTarget:self action:@selector(categorySelect) forControlEvents:UIControlEventTouchUpInside];
    
    self.categorySelectButton = [[UIBarButtonItem alloc] init];
    [categorySelectButton setCustomView:categoryButton];
    
    NSArray *viewOptionItems = [NSArray arrayWithObjects:@"전체",@"즐겨찾기",nil];
    
    viewOption = [[UISegmentedControl alloc] initWithItems:viewOptionItems];
    CGRect viewOptionRect = CGRectMake(0, 0, 130, 35);
    [viewOption setFrame:viewOptionRect];
    viewOption.segmentedControlStyle = UISegmentedControlStyleBar;
    viewOption.selectedSegmentIndex = 0;
    [viewOption addTarget:self
                         action:@selector(viewOptionChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    viewOption.alpha = 0.1;
    UIView *viewOptionView = [[UIView alloc] initWithFrame:viewOptionRect];
    
    self.viewOptionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"B1_on.png"]];
    //[self.viewOptionImageView release];
    viewOptionImageView.frame = viewOptionRect;
    
    [viewOptionView addSubview:viewOption];
    [viewOptionView addSubview:viewOptionImageView];
    [viewOptionImageView release];
    
    self.viewOptionButton = [[UIBarButtonItem alloc] init];
    [viewOptionButton setCustomView:viewOptionView];
    [viewOptionView release];
    
    NSArray *sortOptionItems = [NSArray arrayWithObjects:@"ㄱㄴㄷ", @"km", nil];
    sortOption = [[UISegmentedControl alloc] initWithItems:sortOptionItems];
    sortOption.segmentedControlStyle = UISegmentedControlStyleBar;
    CGRect sortOptionRect = CGRectMake(0, 0, 81, 35);
    [sortOption setFrame:sortOptionRect];
    sortOption.selectedSegmentIndex = 0;

    [sortOption addTarget:self
                   action:@selector(sortOptionChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    sortOption.alpha = 0.1;
    UIView *sortOptionView = [[UIView alloc] initWithFrame:sortOptionRect];
    self.sortOptionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"B2_on.png"]];
    //[self.sortOptionImageView release];
    self.sortOptionImageView.frame = sortOptionRect;
    
    [sortOptionView addSubview:sortOption];
    [sortOptionView addSubview:sortOptionImageView];
    [sortOptionImageView release];
    
    self.sortOptionButton = [[UIBarButtonItem alloc] init];
    [sortOptionButton setCustomView:sortOptionView];
    [sortOptionView release];
    
    [toolbar setItems:[NSArray arrayWithObjects:categorySelectButton, viewOptionButton, sortOptionButton ,nil]];
    [self.categorySelectButton release];
    [self.viewOptionButton release];
    [self.sortOptionButton release];
    
    //Add the toolbar as a subview to the navigation controller.
	[self.navigationController.view addSubview:toolbar];
}

-(void)setToolbarBack:(NSString*)bgFilename toolbar:(UIToolbar*)bottombar 
{   
    // Add Custom Toolbar
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgFilename]];
    iv.frame = CGRectMake(0, 0, bottombar.frame.size.width, bottombar.frame.size.height);
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // Add the tab bar controller's view to the window and display.
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5)
        [bottombar insertSubview:iv atIndex:1]; // iOS5 atIndex:1
    else
        [bottombar insertSubview:iv atIndex:0]; // iOS4 atIndex:0
    [iv release];
    
    bottombar.backgroundColor = [UIColor clearColor];
}


- (void) categorySelect
{
    @try {
        
		NSLog(@"category select.");
        
        CategoryViewController *categoryViewController = [[CategoryViewController alloc] init];
        categoryViewController.view.frame = [[UIScreen mainScreen] bounds];
        categoryViewController.view.opaque = NO;
        categoryViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        categoryViewController.delegate = self;
        
        //    [self.view addSubview:categoryViewController.view];
        [self.navigationController.view addSubview:categoryViewController.view];
        
	}
    @catch (NSException* ex) {
		NSLog(@"categorySelect failed: %@",ex);
	}
}

- (void) viewOptionChanged:(id) sender
{
    if ( viewOption.selectedSegmentIndex == 0)
    {
        self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on.png"];
    }
    else
    {
        self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on2.png"];
    }
    
    [self tabButton1Clicked:nil];
}

-(void) sortOptionChanged:(id) sender
{
    if ( sortOption.selectedSegmentIndex == 0 )
    {
        sortOptionImageView.image = [UIImage imageNamed:@"B2_on.png"];
    }
    else if ( sortOption.selectedSegmentIndex == 1 )
    {
        sortOptionImageView.image = [UIImage imageNamed:@"B2_on2.png"];
    }
    
    if ( sortOption.selectedSegmentIndex == 0 )
    {
        if ( selectedTabIndex == 0 )
        {
            [self tabButton1Clicked:nil];
        }
        else if ( selectedTabIndex == 1 )
        {
            [self tabButton2Clicked:nil];
        }
    }
    else {
        [locationManager startUpdatingLocation];
    }
}

-(void) tabButton1Clicked:(id) sender
{
    if ( [DYViewController isRetinaDisplay] )
        myTableView.frame = CGRectMake(0, 42, 320, 421);
    else
        myTableView.frame = CGRectMake(0, 42, 320, 331);
    
    [self.navigationController.view addSubview:toolbar];
    self.navigationItem.rightBarButtonItem = mapButton;
    
    selectedTabIndex = 0;

    [tableData removeAllObjects];
    [myTableView reloadData];

    if ( viewOption.selectedSegmentIndex == 0 )
    {
        [self performSelector:@selector(updateShopList) withObject:nil afterDelay:0.0];   
    }
    else {
        self.favoritesShopList = [dataManager favoriteShopList];
        [self.tableData addObjectsFromArray:self.favoritesShopList];
        [myTableView reloadData];
    }
    
    [tabButton1 setImage:[UIImage imageNamed:@"tap_01_on.png"] forState:UIControlStateNormal];
    [tabButton2 setImage:[UIImage imageNamed:@"tap_02_off.png"] forState:UIControlStateNormal];
    [tabButton3 setImage:[UIImage imageNamed:@"tap_03_off.png"] forState:UIControlStateNormal];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:categorySelectButton, viewOptionButton, sortOptionButton , nil] 
                  animated:NO];
}

- (void) updateShopList
{
    if ( [[[DataManager sharedDataManager] metaInfoString:@"SHOP_UPDATING"] isEqualToString:@"Y"] == NO )
    {
        NSString *category = [[DataManager sharedDataManager] metaInfoString:@"LAST_SELECTED_CATEGORY"];
        self.shopList = [dataManager shopListWithCategory:category];
        
        if ( selectedTabIndex != 0 ) return;
        
        [self.tableData addObjectsFromArray:self.shopList];
        [myTableView reloadData];
    }
    
    if ( [tableData count] == 0 )
        [self performSelector:@selector(updateShopList) withObject:nil afterDelay:1.0];
}

-(void) tabButton2Clicked:(id) sender
{
    if ( [DYViewController isRetinaDisplay] )
        myTableView.frame = CGRectMake(0, 42, 320, 421);
    else
        myTableView.frame = CGRectMake(0, 42, 320, 331);
    
    [self.navigationController.view addSubview:toolbar];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,sortOptionButton, nil] animated:NO];
    [flexibleSpace release];
    
    self.navigationItem.rightBarButtonItem = mapButton;
    
    selectedTabIndex = 1;
    
    [tableData removeAllObjects];
    [myTableView reloadData];
    
    [self performSelector:@selector(updateNewShopList) withObject:nil afterDelay:0.0];   
    
    [tabButton1 setImage:[UIImage imageNamed:@"tap_01_off.png"] forState:UIControlStateNormal];
    [tabButton2 setImage:[UIImage imageNamed:@"tap_02_on.png"] forState:UIControlStateNormal];
    [tabButton3 setImage:[UIImage imageNamed:@"tap_03_off.png"] forState:UIControlStateNormal];
}

- (void) updateNewShopList
{
    if ( [[[DataManager sharedDataManager] metaInfoString:@"NEW_SHOP_UPDATING"] isEqualToString:@"Y"] == NO )
    {
        self.recentlyOpenedShopList = [dataManager newShopList];
        
        if ( selectedTabIndex != 1 ) return;
        
        [self.tableData addObjectsFromArray:recentlyOpenedShopList];
        [myTableView reloadData];
    }
    
    if ( [tableData count] == 0 )
        [self performSelector:@selector(updateMenuList) withObject:nil afterDelay:1.0];    
}

-(void) tabButton3Clicked:(id) sender
{
    [self.toolbar removeFromSuperview];
    
    if ( [DYViewController isRetinaDisplay] )
        myTableView.frame = CGRectMake(0, 42, 320, 465);
    else
        myTableView.frame = CGRectMake(0, 42, 320, 375);
    
    self.navigationItem.rightBarButtonItem = nil;
        
    selectedTabIndex = 2;
    
    [tableData removeAllObjects];
    [myTableView reloadData];
    
    [self performSelector:@selector(updateMenuList) withObject:nil afterDelay:0.0];
    
    [tabButton1 setImage:[UIImage imageNamed:@"tap_01_off.png"] forState:UIControlStateNormal];
    [tabButton2 setImage:[UIImage imageNamed:@"tap_02_off.png"] forState:UIControlStateNormal];
    [tabButton3 setImage:[UIImage imageNamed:@"tap_03_on.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, viewOptionButton , flexibleSpace, nil] animated:YES];
    [flexibleSpace release];
}

- (void) updateMenuList
{
    if ( [[[DataManager sharedDataManager] metaInfoString:@"MENU_UPDATING"] isEqualToString:@"Y"] == NO )
    {
        if ( menuList == nil || [menuList count] == 0 )
            self.menuList = [dataManager menuAndGroupList];
        
        if ( selectedTabIndex != 2 ) return;
        
        [self.tableData addObjectsFromArray:self.menuList];
        [myTableView reloadData];
    }
    
    if ( [tableData count] == 0 )
        [self performSelector:@selector(updateMenuList) withObject:nil afterDelay:1.0];    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ( viewOption.selectedSegmentIndex == 0 && [tableData count] == 0 )
        return 1;
    else
        return [tableData count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if ( [tableData count] == 0 )
    {
        if ( selectedTabIndex == 2 )
            return 330;
        else
            return 300;
    }
    if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[MenuGroup class]] )
        return 90;
    else return 120;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    if ( [tableData count] == 0 )
    {
        CellIdentifier = @"EmptyCell";
    }
    else {
        if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[MenuGroup class]] )
            CellIdentifier = @"MenuGroupCell";
        else if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[Shop class]] )
            CellIdentifier = @"ShopCell";
        else if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[Menu class]] )
            CellIdentifier = @"MenuCell";    
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if ( [CellIdentifier isEqualToString:@"ShopCell"] )
        {
            cell = [[[ShopCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( [CellIdentifier isEqualToString:@"MenuGroupCell"] )
        {
            cell = [[[MenuGroupCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
        {
            cell = [[[MenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( [CellIdentifier isEqualToString:@"EmptyCell"] )
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIActivityIndicatorView *waitView = 
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            waitView.frame = CGRectMake( 20, 125, 50, 50 );
            waitView.tag = 1;
            [cell.contentView addSubview:waitView];
            [waitView release];
            [waitView startAnimating];
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 134, 220, 30)];
            textLabel.font = [UIFont boldSystemFontOfSize:15];
            textLabel.textAlignment = UITextAlignmentCenter;
            textLabel.textColor = [UIColor grayColor];
            textLabel.tag = 2;
            [cell.contentView addSubview:textLabel];
            [textLabel release];
        }
    }
	
	if ( [CellIdentifier isEqualToString:@"ShopCell"] )
	{
        Shop *shop = (Shop *) [tableData objectAtIndex:indexPath.row];
        ShopCell *c = (ShopCell*) cell;
        c.parentController = self;
        [c setData:shop];
	}
    else if ( [CellIdentifier isEqualToString:@"MenuGroupCell"] )
    {
        MenuGroup *menuGroup = (MenuGroup *) [tableData objectAtIndex:indexPath.row];
        MenuGroupCell *c = (MenuGroupCell *) cell;
        [c setData:menuGroup];
    }
    else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
    {
        Menu *menu = (Menu *) [tableData objectAtIndex:indexPath.row];
        MenuCell *c = (MenuCell *) cell;
        c.parentController = self;
        [c setData:menu bShowPrice:bNeverShowPrice];
    }
    else {
        UILabel *textLabel = (UILabel *) [cell viewWithTag:2];
        
        if ( selectedTabIndex == 0 )
        {
            if ( [[[DataManager sharedDataManager] metaInfoString:@"SHOP_UPDATING"] isEqualToString:@"Y"] )
                textLabel.text = @"업체정보를 업데이트하는 중입니다.";
            else {
                textLabel.text = @"업체정보를 로딩하는 중입니다.";
            }
        }
        else if ( selectedTabIndex == 1 )
        {
            if ( [[[DataManager sharedDataManager] metaInfoString:@"NEW_SHOP_UPDATING"] isEqualToString:@"Y"] )
                textLabel.text = @"신규업체정보를 업데이트하는 중입니다.";
            else {
                textLabel.text = @"신규업체정보를 로딩하는 중입니다.";
            }
        }
        else if ( selectedTabIndex == 2 )
        {
            if ( [[[DataManager sharedDataManager] metaInfoString:@"MENU_UPDATING"] isEqualToString:@"Y"] )
                textLabel.text = @"메뉴정보를 업데이트하는 중입니다.";
            else {
                textLabel.text = @"메뉴정보를 로딩하는 중입니다.";
            }
        }
            
    }
    
    return cell;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return NO;
 }

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

- ( void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

    self.selectedIndexPath = indexPath;

    if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[MenuGroup class]] )
    {
        NSMutableArray *menuListWithMenuGroup = 
            [dataManager menuListWithMenuGroup:[tableData objectAtIndex:indexPath.row]];
        
        if ( [menuListWithMenuGroup count] == 1 )
        {
            Menu *menu = [menuListWithMenuGroup objectAtIndex:0];
            Shop *shop = [[dataManager shopWithSeq:menu.shopSeq] retain];
            shop.menuList = [dataManager menuList:shop.seq];
            
            int menuIndex = 0;
            
            for ( int i = 0; i < [shop.menuList count]; i++ ) 
            {
                Menu *m = (Menu *) [shop.menuList objectAtIndex:i];
                if ( m.menuSeq == menu.menuSeq )
                {
                    menuIndex = i;
                    break;
                }
            }
            
            KoreanShopDetailViewController *detailViewController = 
            [[KoreanShopDetailViewController alloc] init];
            detailViewController.title = [shop shopName];
            detailViewController.shop = shop;
            detailViewController.scrollToMenuIndex = menuIndex;
            [shop release];
            
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
        }
        else
        {
            [tableData removeAllObjects];
            [tableData addObjectsFromArray:menuListWithMenuGroup];
            [myTableView reloadData];   
        }
    }
    else if ( [[tableData objectAtIndex:indexPath.row] isMemberOfClass:[Menu class]] )
    {
       
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return nil;
}

#pragma mark -
#pragma mark UISearchbar delegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar2
{
	// only show the status bar’s cancel button while in edit mode
	searchBar2.showsCancelButton = YES;
	searchBar2.autocorrectionType = UITextAutocorrectionTypeNo;	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar2
{
	searchBar2.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText
{
    if ( selectedTabIndex == 0 || selectedTabIndex == 1 )
        [self updateShop:nil];
    else {
        [self updateMenuList];
    }
    
    if ( searchText == nil || [searchText isEqualToString:@""] ) 
    {
        return;
    }
    
    NSMutableArray *searchData = [[[NSMutableArray alloc] init] autorelease];

    for (int i = 0; i < [tableData count]; i++ ) {
    
        if ( [[tableData objectAtIndex:i] isMemberOfClass:[Shop class]] )
        {
            Shop *shop = (Shop *) [tableData objectAtIndex:i];
            if ( [[shop.shopName lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 )
                [searchData addObject:shop];
        }
        else if ( [[tableData objectAtIndex:i] isMemberOfClass:[MenuGroup class]] )
        {
            MenuGroup *menuGroup = (MenuGroup *) [tableData objectAtIndex:i];
            
            if ( [[menuGroup.menuName lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 )
            {
                [searchData addObject:menuGroup];
            }
        }
        else if ( [[tableData objectAtIndex:i] isMemberOfClass:[Menu class]] )
        {
            Menu *menu = (Menu *) [tableData objectAtIndex:i];
            
            if ( [[menu.menuName lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 )
            {
                [searchData addObject:menu];
            }
        }
    }

    [tableData removeAllObjects];
    [tableData addObjectsFromArray:searchData];
    [myTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar2
{   
    [searchBar2 resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar2
{
    [searchBar2 resignFirstResponder];
}


#pragma mark Location Manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    @try {
        
        //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
        if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     
            self.currentLocation = newLocation;
            
            NSLog(@"%@", currentLocation );
            
            [locationManager stopUpdatingLocation];
            [locationManager stopUpdatingHeading];
            
            if ( selectedTabIndex == 2 ) return;
            
            for (Shop *shop in tableData) {
                if ( shop.latitude != kLocationEmpty )
                {
                    CLLocation *pointALocation = 
                    [[CLLocation alloc] initWithLatitude:shop.latitude longitude:shop.longitude];
                    shop.metersFromCurrentLocation = [currentLocation distanceFromLocation:pointALocation];
                    shop.distance = [NSString stringWithFormat:@"%0.1fkm", shop.metersFromCurrentLocation / 1000.0];
                    [pointALocation release];
                }
            }
            
            NSArray *ar =  [tableData sortedArrayUsingSelector:@selector(compare:)];
            [tableData removeAllObjects];
            [tableData addObjectsFromArray:ar];
            [myTableView reloadData];
        }
        
	}
    @catch (NSException* ex) {
		NSLog(@"categorySelect failed: %@",ex);
	}
}

#pragma mark CategoryViewDelegate methods

-(void) didSelectCategory:(NSString *)category
{
    MetaInfo *metaInfo = [[MetaInfo alloc] init];
    metaInfo.name = @"LAST_SELECTED_CATEGORY";
    metaInfo.value = category;
    [dataManager insertMetaInfo:metaInfo];
    [metaInfo release];
    
    [self tabButton1Clicked:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
    self.shopList = nil;
    self.favoritesShopList = nil;
    self.recentlyOpenedShopList = nil;
    self.menuList = nil;
    self.tableData = nil;
    self.mapButton = nil;
    self.toolbar = nil;
    self.dataManager = nil;
    self.searchBar = nil;
    self.selectedIndexPath = nil;
    self.locationManager = nil;
    self.currentLocation = nil;
    
    self.viewOptionImageView = nil;
    self.sortOptionImageView = nil;
    
    self.tempMenu = nil;
    self.tempShop = nil;
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
    
    [shopList release];
    [favoritesShopList release];
    [recentlyOpenedShopList release];
    [menuList release];
    [tableData release];
    
    [mapButton release];
    [toolbar release];
    [searchBar release];
    [selectedIndexPath release];
    [locationManager release];
    [currentLocation release];
    
    [navTitleView release];
    
    [categorySelectButton release];
    [viewOptionButton release];
    [sortOptionButton release];
    [tabButton1 release];
    [tabButton2 release];
    [tabButton3 release];
    
    [viewOption release];
    [sortOption release]; 
    [viewOptionImageView release];
    [sortOptionImageView release];
    [tempShop release];
    [tempMenu release];
    [dataManager release];
}

@end
