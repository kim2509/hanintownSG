//
//  UserLikesNCommentsViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserLikesNCommentsViewController.h"
#import "common.h"
#import "Cells.h"
#import "MyToolBar.h"

@implementation UserLikesNCommentsViewController

@synthesize object, data, comments, tempObject;

- (void)viewDidLoad 
{
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    if ( [DYViewController isRetinaDisplay] )
    {
        myTableView.frame = CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y,
                                       myTableView.frame.size.width, myTableView.frame.size.height + 90 );
    }
    
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 63, 32 )] autorelease];
    titleLabel.text = @"Back";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *unLikeButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [unLikeButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    unLikeButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [unLikeButtonCustom addTarget:self action:@selector(unLike) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 63, 32 )] autorelease];
    titleLabel2.text = @"Unlike";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [unLikeButtonCustom addSubview:titleLabel2];
    
    unLikeButton = [[UIBarButtonItem alloc] initWithCustomView:unLikeButtonCustom];
    
    UIButton *likeButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    likeButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [likeButtonCustom addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* likeButtonLabel = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(0, 0, 63, 32 )] autorelease];
    likeButtonLabel.text = @"Like";
    likeButtonLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    likeButtonLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    likeButtonLabel.backgroundColor = [UIColor clearColor];
    likeButtonLabel.textAlignment = UITextAlignmentCenter;
    
    [likeButtonCustom addSubview:likeButtonLabel];
    
    likeButton = [[UIBarButtonItem alloc] initWithCustomView:likeButtonCustom];
    
    data = [[NSMutableArray alloc] init];
    
    myTableView.separatorColor = [UIColor whiteColor];
    myTableView.backgroundColor = [UIColor colorWithHexString:@"#ebedf3"];
}

-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) unLike
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    int userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
    
    if ( [object isKindOfClass:[Shop class]] )
    {
        Shop *shop = (Shop *) object;
        ShopLike *shopLike = [[DataManager sharedDataManager] shopLikeWithUserNo:userNo shopNo:shop.seq];
        [[TransactionManager sharedManager] unLikeShop:shopLike];
    }
    else if ( [object isKindOfClass:[Menu class]] )
    {
        Menu *menu = (Menu *) object;
        MenuLike *menuLike = [[DataManager sharedDataManager] menuLikeWithUserNo:userNo shopNo:menu.menuSeq];
        [[TransactionManager sharedManager] unLikeMenu:menuLike];
    }
}

-(void) like
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    int userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
    
    if ( [object isKindOfClass:[Shop class]] )
    {
        Shop *shop = (Shop *) object;
        
        ShopLike *shopLike = [[ShopLike alloc] init];
        shopLike.shopLikeNo = -1;
        shopLike.shopNo = shop.seq;
        shopLike.userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
        
        [[TransactionManager sharedManager] addShopLike:shop shoplike:shopLike];
        [shopLike release];
    }
    else if ( [object isKindOfClass:[Menu class]] )
    {
        Menu *menu = (Menu *) object;
        MenuLike *menuLike = [[MenuLike alloc] init];
        menuLike.menuLikeNo = -1;
        menuLike.menuNo = menu.menuSeq;
        menuLike.userNo = userNo;
        
        [[TransactionManager sharedManager] addMenuLike:menu shoplike:menuLike];
        [menuLike release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadLikes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateLikes:) name:@"UserLikesNCommentsUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deleteCommentTouched:) name:@"DeleteComment" object:nil];
}

-(void) loadLikes
{
    [data removeAllObjects];
    
    int userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
    
    BOOL bYouLike;
    int countOfLikes;
    
    if ( [object isKindOfClass:[Shop class]] )
    {
        Shop *shop = (Shop *) object;
        
        self.title = shop.shopName;
        
        bYouLike = [[DataManager sharedDataManager] doesUserLikeShop:userNo shopNo:shop.seq];
        countOfLikes = [[DataManager sharedDataManager] countShopLikes:shop.seq];
        
        self.comments = [[DataManager sharedDataManager] shopCommentsWithSeq:shop.seq];
    }
    else if ( [object isKindOfClass:[Menu class]] )
    {
        Menu *menu = (Menu *) object;
        
        self.title = menu.menuName;
        
        bYouLike = [[DataManager sharedDataManager] doesUserLikeMenu:userNo menuNo:menu.menuSeq];
        countOfLikes = [[DataManager sharedDataManager] countMenuLikes:menu.menuSeq];
        
        self.comments = [[DataManager sharedDataManager] menuCommentsWithSeq:menu.menuSeq];
    }
    
    if ( bYouLike )
    {
        self.navigationItem.rightBarButtonItem = unLikeButton;
        
        if ( countOfLikes == 1 )
            [data addObject:[NSString stringWithFormat:@"당신이 좋아합니다.", countOfLikes - 1]];
        else
            [data addObject:[NSString stringWithFormat:@"당신, %d명의 이용자가 좋아합니다.", countOfLikes - 1]];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = likeButton;
        
        [data addObject:[NSString stringWithFormat:@"%d명의 이용자가 좋아합니다.", countOfLikes]];
    }
}

-(void) deleteCommentTouched:(NSNotification *) notification
{
    if ( [self isAlreadyLogin] == NO )
    {
        [self showModalLoginViewController];
        return;
    }
    
    self.tempObject = notification.object;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"정말로 삭제하시겠습니까?" message:nil 
                                                   delegate:self cancelButtonTitle:@"Yes" 
                                          otherButtonTitles:@"No",nil];
    
    [alert show];
    [alert autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        if ( [tempObject isKindOfClass:[ShopComment class]] )
        {
            [[TransactionManager sharedManager] deleteShopComment:(ShopComment *) tempObject];
        }
        else if ( [tempObject isKindOfClass:[MenuComment class]] )
        {
            [[TransactionManager sharedManager] deleteMenuComment:(MenuComment *) tempObject];
        }
    }
}

-(void) updateLikes:(NSNotification *)notification
{
    [self loadLikes];
    [myTableView reloadData];
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

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ( section == 0 || section == 1 )
        return 1;
    else
        return [comments count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int h = 0;
    
	if ( indexPath.section == 0 )
        h = 90;
    else if ( indexPath.section == 1 )
        h = 40;
    else if ( indexPath.section == 2 )
    {
        if ( [object isKindOfClass:[Shop class]] )
        {
            ShopComment *shopComment = [comments objectAtIndex:indexPath.row];
            CGSize size = [Util heightForCellWithText:shopComment.comment        
                                                 size:CGSizeMake(245, 500) 
                                                 font:[UIFont systemFontOfSize:14]];
            h = size.height + 20;
        }
        else if ( [object isKindOfClass:[Menu class]] )
        {
            MenuComment *menuComment = [comments objectAtIndex:indexPath.row];
            CGSize size = [Util heightForCellWithText:menuComment.comment        
                                                 size:CGSizeMake(245, 500) 
                                                 font:[UIFont systemFontOfSize:14]];
            h = size.height + 20;
        }
    }

    return h;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    if ( indexPath.section == 0 )
    {
        if ( [object isKindOfClass:[Shop class] ] )
            CellIdentifier = @"ShopCell";
        else
            CellIdentifier = @"MenuCell";
    }
    else if ( indexPath.section == 1 )
        CellIdentifier = @"LikesCell";
    else if ( indexPath.section == 2 )
        CellIdentifier = @"CommentsCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if ( [CellIdentifier isEqualToString:@"ShopCell"] )
        {
            cell = [[ShopCell2 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ShopCell"];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
        {
            cell = [[MenuCell3 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MenuCell"];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else if ( [CellIdentifier isEqualToString:@"LikesCell"] )
        {
            /*
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] 
                    autorelease];
             */
            cell = [[[LikeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] 
                    autorelease];
        }
        else if ( [CellIdentifier isEqualToString:@"CommentsCell"] )
        {
            cell = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] 
                    autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if ( [CellIdentifier isEqualToString:@"ShopCell"] )
	{
        ShopCell *c = (ShopCell*) cell;
        [c setData:(Shop *)object];
	}
    else if ( [CellIdentifier isEqualToString:@"MenuCell"] )
	{
        MenuCell3 *c = (MenuCell3*) cell;
        
        Menu *menu = (Menu *)object;
        Shop *shop = [[DataManager sharedDataManager] shopWithSeq:menu.shopSeq];
        
        bool bNeverShowPrice = false;
        
        MetaInfo *neverShowPriceInfo = [[DataManager sharedDataManager] getMetaInfo:@"NEVER_SHOW_PRICE"];
        if ( neverShowPriceInfo != nil && neverShowPriceInfo.value != nil && 
            [neverShowPriceInfo.value isEqualToString:@""] == NO )
        {
            bNeverShowPrice = [neverShowPriceInfo.value boolValue];
        }
        
        [c setData:menu shop:shop bNeverShowPrice:bNeverShowPrice];
	}
    else if ( [CellIdentifier isEqualToString:@"LikesCell"] )
    {
        LikeCell *c = (LikeCell*) cell;
        
        [c setLikeText:[data objectAtIndex:0]];
    }
    else if ( [CellIdentifier isEqualToString:@"CommentsCell"] )
    {
        CommentCell *c = (CommentCell*) cell;
        int userNo = [[[DataManager sharedDataManager] metaInfoString:@"USER_NO"] intValue];
        
        if ( [[comments objectAtIndex:indexPath.row] isKindOfClass:[ShopComment class]] )
        {
            ShopComment *shopComment = [comments objectAtIndex:indexPath.row];
            c.object = shopComment;
            [c setComment:shopComment.comment delete:(shopComment.userNo == userNo )];
        }
        else if ( [[comments objectAtIndex:indexPath.row] isKindOfClass:[MenuComment class]] )
        {
            MenuComment *menuComment = [comments objectAtIndex:indexPath.row];
            c.object = menuComment;
            [c setComment:menuComment.comment delete:(menuComment.userNo == userNo )];
        }
        
        c.contentView.backgroundColor = [UIColor colorWithHexString:@"#ebedf3"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}


- (void) viewDidUnload
{
    self.object = nil;
    self.data = nil;
    self.comments = nil;
    
}

- (void)dealloc {
    [comments release];
    [object release];
    [data release];
    [super dealloc];
}

@end
