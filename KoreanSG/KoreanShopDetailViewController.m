//
//  KoreanShopDetailViewController.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KoreanShopDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AddressAnnotation.h"
#import "Menu.h"
#import "MetaInfo.h"
#import "Cells.h"
#import "CommentInputViewController.h"
#import "UserLikesNCommentsViewController.h"

@implementation KoreanShopDetailViewController

@synthesize detailInfo,toolbar,shop, scrollToMenuIndex, tempMenu;

- (id)init {
    self = [super init];
    if (self) {
        scrollToMenuIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    detailInfo = [[NSMutableDictionary alloc] init];
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStylePlain];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    
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
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addLikesNComments:) name:@"AddLikesNComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateLikesNComments:) 
                                                 name:@"UserLikesNCommentsUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addComment:) name:@"AddComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(viewLikesNComments:) name:@"ViewLikesNComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(menuImageSelected:) name:@"MenuImageSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(becomeForeground:) name:@"becomeForeground" object:nil];
    
    DataManager *dataManager = [DataManager sharedDataManager];
    MetaInfo *neverShowPriceInfo = [dataManager getMetaInfo:@"NEVER_SHOW_PRICE"];
    if ( neverShowPriceInfo != nil && neverShowPriceInfo.value != nil && 
        [neverShowPriceInfo.value isEqualToString:@""] == NO )
    {
        bNeverShowPrice = [neverShowPriceInfo.value boolValue];
    }
    
    if ( shop == nil )
        shop = [[Shop alloc] init];
    
    [myTableView reloadData];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    if ( scrollToMenuIndex == -1 ) return;
    
    NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:scrollToMenuIndex inSection:2];
    [myTableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void) becomeForeground:(NSNotification *)notification
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

-(void) menuImageSelected:(NSNotification *)notification
{
    self.tempMenu = notification.object;
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"사진을 업로드 하시겠습니까?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo album", nil];
    
    popupQuery.tag = 2;
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
    [popupQuery release];
}

-(void) addLikesNComments:(NSNotification *)notification
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    if ( [notification.object isKindOfClass:[Menu class]] )
        self.tempMenu = notification.object;
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"리뷰를 남기시겠습니까?\n(익명으로 남기게 됩니다.)" 
                                                            delegate:self cancelButtonTitle:@"Cancel" 
                                              destructiveButtonTitle:nil otherButtonTitles:@"Like", @"Comment", nil];
    
    popupQuery.tag = 1;
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
    [popupQuery release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == 1 )
    {
        if ( buttonIndex == 0 )
        {
            if ( self.tempMenu != nil )
            {
                MenuLike *menuLike = [[MenuLike alloc] init];
                menuLike.menuLikeNo = -1;
                menuLike.menuNo = self.tempMenu.menuSeq;
                menuLike.userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
                
                [[TransactionManager sharedManager] addMenuLike:self.tempMenu shoplike:menuLike];
                [menuLike release];
            }
            
            self.tempMenu = nil;
        }
        else if ( buttonIndex == 1 )
        {
            CommentInputViewController *commentInputViewController = [[CommentInputViewController alloc] init];
            
            UINavigationController *commentNavController = 
            [[UINavigationController alloc] initWithRootViewController:commentInputViewController];
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
        
        url = [NSURL URLWithString:[Constants uploadMenuImageURL]];
        fileName = [NSString stringWithFormat:@"M%d.png",self.tempMenu.menuSeq];
        
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

-(void) addComment:(NSNotification *)notification
{
    if ( self.tempMenu != nil )
    {
        MenuComment *menuComment = [[MenuComment alloc] init];
        menuComment.menuCommentNo = -1;
        menuComment.menuNo = self.tempMenu.menuSeq;
        menuComment.userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
        menuComment.comment = notification.object;
        [[DataManager sharedDataManager] insertMenuComment:menuComment];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
        [[TransactionManager sharedManager] addMenuComment:self.tempMenu shopComment:menuComment];
        [menuComment release];
    }
    
    self.tempMenu = nil;
}

-(void) updateLikesNComments:(NSNotification *)notification
{
    shop.menuList = [[DataManager sharedDataManager] menuList:shop.seq];
    [myTableView reloadData];
}

-(void) viewLikesNComments:(NSNotification *)notfication
{
    UserLikesNCommentsViewController *userLikesNCommentsViewController = 
    [[UserLikesNCommentsViewController alloc] init];
    userLikesNCommentsViewController.object = notfication.object;
    
    [self.navigationController pushViewController:userLikesNCommentsViewController animated:YES];
    [userLikesNCommentsViewController release];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [locationManager stopUpdatingLocation];
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
        return 1;
    else if ( section == 1 )
        return 1;
    else if ( section == 2 )
        return [[shop menuList] count];
    
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger) section
{    
    if ( section == 2 && [[shop menuList] count] > 0 )
        return @"메뉴정보";
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2 && [[shop menuList] count] > 0)
        return 30;
    else return 0;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    if (section == 2 && [[shop menuList] count] > 0 )
    {
        [headerView setBackgroundColor:[UIColor colorWithHexString:@"#d8dfea"]];
        
        UILabel* titleLabel = [[[UILabel alloc] 
                                initWithFrame:CGRectMake(0, 5, 94, 20 )] autorelease];
        titleLabel.text = @"메뉴정보";
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor colorWithHexString:@"#3b5999"];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    else return nil;
}


-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if ( indexPath.section == 0 )
        return 190;
    else if ( indexPath.section == 1 )
        return 200;
    else if ( indexPath.section == 2 )
        return 120;
    else
        return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    if ( indexPath.section == 0 )
    {
        CellIdentifier = @"MapCell";
    }
    else if ( indexPath.section == 1 )
    {
        CellIdentifier = @"BasicInfoCell";
    }
    else if ( indexPath.section == 2 )
        CellIdentifier = @"MenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if ( [CellIdentifier isEqualToString:@"MapCell"] )
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            
            mapView = [[MKMapView alloc] initWithFrame:CGRectMake(10, 10, 300, 130)];
            mapView.layer.cornerRadius = 10.0;
            mapView.delegate = self;
            mapView.layer.borderColor = [UIColor colorWithHexString:@"#3b5999"].CGColor;
            mapView.layer.borderWidth = 1.0f;
            [cell.contentView addSubview:mapView];
            [mapView release];
            
            [self addHeaderInfoButtonsToCell:cell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( [CellIdentifier isEqualToString:@"BasicInfoCell"] )
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            
            [self customizeBasicInfoCell:cell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
        {
            cell = [[[MenuCell2 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MenuCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
	
	if ( [CellIdentifier isEqualToString:@"MapCell"] )
    {
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#d8dfea"];
        
        if ( [[DataManager sharedDataManager] existsInFavorites:shop] )
            favoritesButton.selected = YES;
        else
            favoritesButton.selected = NO;
        
        CLLocationCoordinate2D location;
        location.longitude = [shop longitude];
        location.latitude = [shop latitude];
        
        /*Region and Zoom*/
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.005;
        span.longitudeDelta=0.005;
        
        region.span=span;
        region.center=location;
        
        NSArray *existingpoints = mapView.annotations;
        if ([existingpoints count] > 0)
            [mapView removeAnnotations:existingpoints];
        
        if ( [shop longitude] == kLocationEmpty ) return cell;
        
        [mapView setRegion:region animated:NO];
        
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
        addAnnotation.mTitle = [shop shopName];
        addAnnotation.mSubTitle = [shop address];
        [mapView addAnnotation:addAnnotation];
        [addAnnotation release];
    }
    else if ( [CellIdentifier isEqualToString:@"BasicInfoCell"] )
    {
        UILabel *shopCategoryLabel = (UILabel *) [cell viewWithTag:1];
        shopCategoryLabel.text = [shop category];
        UIButton *phoneNoBtn = (UIButton *) [cell viewWithTag:2];
        [phoneNoBtn setTitle:[shop phone] forState:UIControlStateNormal];
        
        UIButton *addressBtn = (UIButton *) [cell viewWithTag:4];
        [addressBtn setTitle:[shop address] forState:UIControlStateNormal];
        
        CGSize labelSize = [addressBtn.titleLabel.text sizeWithFont:addressBtn.titleLabel.font 
                                    constrainedToSize:CGSizeMake(240, 60) 
                                        lineBreakMode:UILineBreakModeWordWrap];
        
        addressBtn.frame = CGRectMake(addressBtn.frame.origin.x,
                                             addressBtn.frame.origin.y, 
                                             labelSize.width, 
                                             labelSize.height );
    }
    else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
    {
        Menu *menu = [[shop menuList] objectAtIndex:indexPath.row];
        MenuCell2 *menuCell = (MenuCell2 *)cell;
        [menuCell setData:menu shop:shop bNeverShowPrice:bNeverShowPrice];
    }

    return cell;
}

- ( void ) addHeaderInfoButtonsToCell:(UITableViewCell *) cell
{
    /*
    UILabel* shopDescLabel = [[[UILabel alloc] 
                            initWithFrame:CGRectMake(10, 0, 320, 40 )] autorelease];
    shopDescLabel.text = [shop shopName];
    shopDescLabel.font = [UIFont boldSystemFontOfSize:18];
    shopDescLabel.textColor = [UIColor colorWithHexString:@"#3b5999"];
    shopDescLabel.backgroundColor = [UIColor clearColor];
    shopDescLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:shopDescLabel];
    */
     
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg03.png"];
    UIButton *directionTo = [UIButton buttonWithType:UIButtonTypeCustom];
    [directionTo setBackgroundImage:buttonImage forState:UIControlStateNormal];
    directionTo.frame = CGRectMake(10,150, 94, 25);
    [directionTo addTarget:self action:@selector(directionTo:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 94, 25 )];
    titleLabel.text = @"Direction To";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [directionTo addSubview:titleLabel];
    [titleLabel release];
    
    [cell.contentView addSubview:directionTo];
    
    UIButton *directionFrom = [UIButton buttonWithType:UIButtonTypeCustom];
    [directionFrom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    directionFrom.frame = CGRectMake(114,150, 94, 25);
    [directionFrom addTarget:self action:@selector(directionFrom:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 94, 25 )];
    titleLabel2.text = @"Direction From";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#ffffff"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [directionFrom addSubview:titleLabel2];
    [titleLabel2 release];
    
    [cell.contentView addSubview:directionFrom];
    
    favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoritesButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [favoritesButton setBackgroundImage:[UIImage imageNamed:@"btn_bg03_on.png"] forState:UIControlStateSelected];
    favoritesButton.tag = 3;
    favoritesButton.frame = CGRectMake(218,150, 94, 25);
    [favoritesButton addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* favoritesLabel = [[UILabel alloc] 
                             initWithFrame:CGRectMake(0, 0, 94, 25 )];
    favoritesLabel.text = @"즐겨찾기추가";
    favoritesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    favoritesLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    favoritesLabel.backgroundColor = [UIColor clearColor];
    favoritesLabel.textAlignment = UITextAlignmentCenter;
    
    [favoritesButton addSubview:favoritesLabel];
    [favoritesLabel release];
    
    [cell.contentView addSubview:favoritesButton];
}

- (void) customizeBasicInfoCell:(UITableViewCell *) cell
{
    int startHeight = 10;
    
    UILabel* cellTitleLabel = [[UILabel alloc] 
                               initWithFrame:CGRectMake(20, startHeight, 320, 40 )];
    cellTitleLabel.text = @"기본정보";
    cellTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    cellTitleLabel.textColor = [UIColor colorWithHexString:@"#020202"];
    cellTitleLabel.backgroundColor = [UIColor clearColor];
    cellTitleLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:cellTitleLabel];
    [cellTitleLabel release];
    
    startHeight += 40;
    
    UILabel* shopCategoryTitleLabel = [[UILabel alloc] 
                                 initWithFrame:CGRectMake(20, startHeight, 40, 20 )];
    shopCategoryTitleLabel.text = @"업종";
    shopCategoryTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    shopCategoryTitleLabel.textColor = [UIColor colorWithHexString:@"#415775"];
    shopCategoryTitleLabel.backgroundColor = [UIColor clearColor];
    shopCategoryTitleLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:shopCategoryTitleLabel];
    [shopCategoryTitleLabel release];
    
    UILabel* shopCategoryValueLabel = [[UILabel alloc] 
                                 initWithFrame:CGRectMake(70, startHeight, 250, 20 )];
    shopCategoryValueLabel.tag = 1;
    shopCategoryValueLabel.font = [UIFont boldSystemFontOfSize:15];
    shopCategoryValueLabel.textColor = [UIColor colorWithHexString:@"#484848"];
    shopCategoryValueLabel.backgroundColor = [UIColor clearColor];
    shopCategoryValueLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:shopCategoryValueLabel];
    [shopCategoryValueLabel release];
    
    startHeight += 25;
    
    UILabel* phoneTitleLabel = [[UILabel alloc] 
                                initWithFrame:CGRectMake(20, startHeight, 40, 20 )];
    phoneTitleLabel.text = @"전화";
    phoneTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    phoneTitleLabel.textColor = [UIColor colorWithHexString:@"#415775"];
    phoneTitleLabel.backgroundColor = [UIColor clearColor];
    phoneTitleLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:phoneTitleLabel];
    [phoneTitleLabel release];
    
    UIButton *phonenoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phonenoBtn.tag = 2;
    [phonenoBtn setFrame:CGRectMake(70, startHeight, 150, 20)];
    [phonenoBtn setTitle:@"Phone" forState:UIControlStateNormal];
    phonenoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [phonenoBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [phonenoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [phonenoBtn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];

    [cell.contentView addSubview:phonenoBtn];
    
    startHeight += 25;
    
    UILabel* openInfoTitleLabel = [[UILabel alloc] 
                                 initWithFrame:CGRectMake(20, startHeight, 40, 20 )];
    openInfoTitleLabel.text = @"오픈";
    openInfoTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    openInfoTitleLabel.textColor = [UIColor colorWithHexString:@"#415775"];
    openInfoTitleLabel.backgroundColor = [UIColor clearColor];
    openInfoTitleLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:openInfoTitleLabel];
    [openInfoTitleLabel release];
    
    UILabel* openInfoValueLabel = [[UILabel alloc] 
                                 initWithFrame:CGRectMake(70, startHeight, 250, 20 )];
    openInfoValueLabel.tag = 3;
    openInfoValueLabel.font = [UIFont boldSystemFontOfSize:15];
    openInfoValueLabel.textColor = [UIColor colorWithHexString:@"#484848"];
    openInfoValueLabel.backgroundColor = [UIColor clearColor];
    openInfoValueLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:openInfoValueLabel];
    [openInfoValueLabel release];
    
    startHeight += 25;
    
    UILabel* addressTitleLabel = [[UILabel alloc] 
                                    initWithFrame:CGRectMake(20, startHeight, 40, 20 )];
    addressTitleLabel.text = @"주소";
    addressTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    addressTitleLabel.textColor = [UIColor colorWithHexString:@"#415775"];
    addressTitleLabel.backgroundColor = [UIColor clearColor];
    addressTitleLabel.textAlignment = UITextAlignmentLeft;
    
    [cell.contentView addSubview:addressTitleLabel];
    [addressTitleLabel release];
    
    UIButton *addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addressBtn.tag = 4;
    [addressBtn setFrame:CGRectMake(70, startHeight, 240, 60 )];
    [addressBtn setTitle:@"Address" forState:UIControlStateNormal];
    addressBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    addressBtn.titleLabel.numberOfLines = 0;
    addressBtn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [addressBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [addressBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addressBtn addTarget:self action:@selector(runMapApp:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:addressBtn];
}

-(void) call :(id) sender
{
    if ( [sender isMemberOfClass:[UIButton class]] )
    {
        UIButton *phoneBtn = (UIButton *) sender;
        
        NSString *url = [NSString stringWithFormat:@"tel://%@", phoneBtn.titleLabel.text];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];        
    }
}

-(void) runMapApp :(id) sender
{
    if ( [sender isMemberOfClass:[UIButton class]] )
    {
        UIButton *addressBtn = (UIButton *) sender;
        
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", 
                         [addressBtn.titleLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        UIApplication *app = [UIApplication sharedApplication];        
        [app openURL:[NSURL URLWithString:url]]; 
    }
}

-(void) directionTo :(id) sender
{
    if ( [sender isMemberOfClass:[UIButton class]] )
    {     
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@", 
                         currentLocation.latitude ,currentLocation.longitude,
                         [shop.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"lat:%f long:%f", currentLocation.latitude, currentLocation.longitude );
        
        UIApplication *app = [UIApplication sharedApplication];        
        [app openURL:[NSURL URLWithString:url]];
    }
}

-(void) directionFrom :(id) sender
{
    if ( [sender isMemberOfClass:[UIButton class]] )
    {     
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%f,%f", 
                         [shop.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         currentLocation.latitude ,currentLocation.longitude];
        
        UIApplication *app = [UIApplication sharedApplication];        
        [app openURL:[NSURL URLWithString:url]];
    }
}

-(void) addToFavorites :(id) sender
{
    DataManager *dataManager = [DataManager sharedDataManager];

    if ( [dataManager existsInFavorites:shop] )
    {
        [dataManager deleteFromFavorites:shop];
        favoritesButton.selected = NO;
    }
    else
    {
        [dataManager insertFavoritesShopTable:shop];
        favoritesButton.selected = YES;
    }
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
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ( indexPath.section == 1 && indexPath.row == 0 )
    {    
        NSString *url = [NSString stringWithFormat:@"tel://%@", [[cell textLabel] text]];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];        
    }
    else if ( indexPath.section == 1 && indexPath.row == 1 )
    {
        NSString *address = [[[cell textLabel] text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", address];
        
        NSLog(@"calling map:%@", url );
        
        UIApplication *app = [UIApplication sharedApplication];        
        [app openURL:[NSURL URLWithString:url]]; 
    }
    */
}


#pragma map view methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView2 viewForAnnotation:(id <MKAnnotation>) annotation{
    
    MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] 
                                  initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
	annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

#pragma mark Location Manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    @try {
        
        NSLog(@"locationManager didUpdateToLocation.." );
        
        //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
        if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     

            currentLocation = newLocation.coordinate;

            [locationManager stopUpdatingLocation];
            
            NSLog(@"current update lat:%f long:%f", currentLocation.latitude, currentLocation.longitude );
            
        }
        
	}
    @catch (NSException* ex) {
		NSLog(@"categorySelect failed: %@",ex);
	}
    
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.detailInfo = nil;
    self.toolbar = nil;
    self.shop = nil;
}


- (void)dealloc {
    [toolbar release];
	[detailInfo release];
    [shop release];    
    [locationManager release];
    [myTableView release];
    
    [super dealloc];
}

@end
