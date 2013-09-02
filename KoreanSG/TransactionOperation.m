//
//  TransactionOperation.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 11. 2..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TransactionOperation.h"
#import "DataModel.h"

@implementation TransactionOperation

@synthesize responseString;

-(void) setUpdateShopInfoData:(NSString *) respString
{
    self.responseString = respString;
    TRANS_MODE = kUpdateShopInfo;    
}

-(void) setUserLikesNComments:(NSString *) respString
{
    self.responseString = respString;
    TRANS_MODE = kUpdateUserLikesNComments;    
}

-(void) main
{
    @try {
     
        [self initVariables];
        
        if ( TRANS_MODE == kUpdateShopInfo )
        {
            [self updateMetaInfo];
            [self updateShopInfo];
            [self updateMenuInfo];
            [self updateNewShopInfo];
            
            [[TransactionManager sharedManager] getUserLikesNComments];
        }
        else if ( TRANS_MODE == kUpdateUserLikesNComments )
        {
            if ( [self needsUpdateForLikesNComments] == NO ) return;
            
            [self updateShopLikes];
            [self updateShopComments];
            [self updateShopCommentLikes];
            [self updateMenuLikes];
            [self updateMenuComments];
            [self updateMenuCommentLikes];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception );
    }
    @finally {
        
    }
}

-(void) initVariables
{
    shopLikesNCommentsUpdated = NO;
    menuLikesNCommentsUpdated = NO;
}

-(BOOL) needsUpdateForLikesNComments
{
    if ( responseString == nil ) return NO;
    
    if ( [responseString JSONValue] == nil ) return NO;
    
    NSDictionary *likesNCommentsDict = (NSDictionary *) [responseString JSONValue];
    
    if ( [likesNCommentsDict count] < 1 ) return NO;
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopLikeInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopLikeList"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopCommentInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopCommentList"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopCommentLikeInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedShopCommentLikeList"] isKindOfClass:[NSNull class]] == NO )
    {
        shopLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuLikeInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuLikeList"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuCommentInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuCommentList"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuCommentLikeInfo"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    if ( [[likesNCommentsDict objectForKey:@"updatedMenuCommentLikeList"] isKindOfClass:[NSNull class]] == NO )
    {
        menuLikesNCommentsUpdated = YES;
        return YES;
    }
    
    return NO;
}

-(void) updateMetaInfo
{
    NSDictionary *resDict = [responseString JSONValue];
    
    if ( resDict != nil && [resDict isKindOfClass:[NSNull class]] == NO )
    {
        NSString *userNo = [resDict objectForKey:@"userNo"];
        NSString *userID = [resDict objectForKey:@"userID"];
        NSString *priceHideList = [resDict objectForKey:@"priceHideList"];
        NSString *nickName = [resDict objectForKey:@"nickName"];
        
        DataManager *dataManager = [DataManager sharedDataManager];
        [[DataManager sharedDataManager] updateShopPriceShowInfo:priceHideList];    
        
        MetaInfo *metaInfo = [[MetaInfo alloc] init];
        
        metaInfo.name = @"NEVER_SHOW_PRICE";
        metaInfo.value = @"FALSE";
        [dataManager insertMetaInfo:metaInfo];
        
        if ( userNo != nil && [@"" isEqualToString:userNo] == NO && [userNo isKindOfClass:[NSNull class]] == NO )
        {
            if ( [@"" isEqualToString:[dataManager metaInfoString:@"USER_NO"]] )
            {
                metaInfo.name = @"USER_NO";
                metaInfo.value = userNo;    
                [dataManager insertMetaInfo:metaInfo];      
            }
        }
        
        if ( userID != nil && [@"" isEqualToString:userID] == NO && [userID isKindOfClass:[NSNull class]] == NO)
        {
            if ( [@"" isEqualToString:[dataManager metaInfoString:@"USER_ID"]] )
            {
                metaInfo.name = @"USER_ID";
                metaInfo.value = userID;    
                [dataManager insertMetaInfo:metaInfo];   
            }
        }
        
        if ( nickName != nil && [@"" isEqualToString:nickName] == NO && [nickName isKindOfClass:[NSNull class]] == NO)
        {
            if ( [@"" isEqualToString:[dataManager metaInfoString:@"NICKNAME"]] )
            {
                metaInfo.name = @"NICKNAME";
                metaInfo.value = nickName;    
                [dataManager insertMetaInfo:metaInfo];   
            }
        }
        
        [metaInfo release];
    }
}

-(void) updateShopInfo
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedShopInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedShopList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"1"];
        
        [[DataManager sharedDataManager] setMetaInfo:@"SHOP_UPDATING" value:@"Y"];
        
        if ( [[[DataManager sharedDataManager] metaInfoString:@"SHOP_INFO_LAST_MODIFIED_DATE"] isEqualToString:@""] )
            [[DataManager sharedDataManager] deleteAllShops];
        
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"shopInfoLastModifiedDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"SHOP_INFO_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteShops:infoValue];
                
                if ( [@"deletedShopList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *shopList = nil;
                
                if ( [@"newShopList" isEqualToString:infoKey] )
                    shopList = [list objectAtIndex:0];
                else if ( [@"updatedShopList" isEqualToString:infoKey] )
                    shopList = [list objectAtIndex:1];
                
                for ( int i = 0; i < [shopList count]; i++ )
                {
                    Shop *shop = [[Shop alloc] initWithDictionaryValues:[shopList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertKoreanShop:shop];
                    [shop release];
                }
            }
        }
        
        // favorite list migration from 1.0 or 1.1 to 1.2
        if ( [[[DataManager sharedDataManager] metaInfoString:@"SHOP_INFO_LAST_MODIFIED_DATE"] isEqualToString:@""] )
        {
            [[DataManager sharedDataManager] migrateNewShopList];
            [[DataManager sharedDataManager] migrateFavoriteShopList];
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
        
        [[DataManager sharedDataManager] setMetaInfo:@"SHOP_UPDATING" value:@"N"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"2"];
    }
}


-(void) updateMenuInfo
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedMenuInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedMenuList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"1"];
        
        [[DataManager sharedDataManager] setMetaInfo:@"MENU_UPDATING" value:@"Y"];
        
        if ( [[[DataManager sharedDataManager] metaInfoString:@"MENU_INFO_LAST_MODIFIED_DATE"] isEqualToString:@""] )
            [[DataManager sharedDataManager] deleteAllMenus];
        
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"menuInfoLastModifiedDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"MENU_INFO_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteMenus:infoValue];
                
                if ( [@"deletedMenuList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *menuList = nil;
                
                if ( [@"newMenuList" isEqualToString:infoKey] )
                    menuList = [list objectAtIndex:0];
                else if ( [@"updatedMenuList" isEqualToString:infoKey] )
                    menuList = [list objectAtIndex:1];
                
                for ( int i = 0; i < [menuList count]; i++ )
                {
                    Menu *menu = [[Menu alloc] initWithDictionaryValues:[menuList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertMenu:menu];
                    [menu release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
        
        [[DataManager sharedDataManager] setMetaInfo:@"MENU_UPDATING" value:@"N"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"2"];
    }
    
}

-(void) updateNewShopInfo
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedNewShopInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedNewShopList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"1"];
        
        [[DataManager sharedDataManager] setMetaInfo:@"NEW_SHOP_UPDATING" value:@"Y"];
        
        if ( [[[DataManager sharedDataManager] metaInfoString:@"NEW_SHOP_INFO_LAST_MODIFIED_DATE"] isEqualToString:@""] )
            [[DataManager sharedDataManager] deleteAllNewShop];
        
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"shopInfoLastModifiedDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"NEW_SHOP_INFO_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteNewShops:infoValue];
                
                if ( [@"deletedShopList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *shopList = nil;
                
                if ( [@"newShopList" isEqualToString:infoKey] )
                    shopList = [list objectAtIndex:0];
                else if ( [@"updatedShopList" isEqualToString:infoKey] )
                    shopList = [list objectAtIndex:1];
                
                for ( int i = 0; i < [shopList count]; i++ )
                {
                    NSDictionary *dic = [shopList objectAtIndex:i];
                    NewShop *newShop = [[NewShop alloc] init];
                    newShop.newShopSeq = [[dic objectForKey:@"NEW_SHOP_NO"] intValue];
                    newShop.shopSeq = [[dic objectForKey:@"SHOP_NO"] intValue];
                    [[DataManager sharedDataManager] insertNewShop:newShop];
                    [newShop release];
                }
            }
        }
                
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
        
        [[DataManager sharedDataManager] setMetaInfo:@"NEW_SHOP_UPDATING" value:@"N"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopUpdate" object:@"2"];
    }
}

-(void) updateShopLikes
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedShopLikeInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedShopLikeList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        [[DataManager sharedDataManager] deleteShopLikes:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"shopLikeLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"SHOP_LIKE_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteShopLikes:infoValue];
                
                if ( [@"deletedShopLikeList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *shopLikeList = nil;
                
                if ( [@"newShopLikeList" isEqualToString:infoKey] )
                    shopLikeList = [list objectAtIndex:0];
                else if ( [@"updatedShopLikeList" isEqualToString:infoKey] )
                    shopLikeList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [shopLikeList count]; i++ )
                {
                    ShopLike *shopLike = [[ShopLike alloc] initWithDictionaryValues:[shopLikeList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertShopLike:shopLike];
                    [shopLike release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
    
}

-(void) updateShopComments
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedShopCommentInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedShopCommentList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        [[DataManager sharedDataManager] deleteShopComments:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"shopCommentLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"SHOP_COMMENT_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteShopComments:infoValue];
                
                if ( [@"deletedShopCommentList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *shopCommentList = nil;
                
                if ( [@"newShopCommentList" isEqualToString:infoKey] )
                    shopCommentList = [list objectAtIndex:0];
                else if ( [@"updatedShopCommentList" isEqualToString:infoKey] )
                    shopCommentList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [shopCommentList count]; i++ )
                {
                    ShopComment *shopComment = [[ShopComment alloc] initWithDictionaryValues:[shopCommentList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertShopComment:shopComment];
                    [shopComment release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
}

-(void) updateShopCommentLikes
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedShopCommentLikeInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedShopCommentLikeList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {   
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        [[DataManager sharedDataManager] deleteShopCommentLikes:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"shopCommentLikeLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"SHOP_COMMENT_LIKE_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteShopCommentLikes:infoValue];
                
                if ( [@"deletedShopCommentLikeList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *shopCommentLikeList = nil;
                
                if ( [@"newShopCommentLikeList" isEqualToString:infoKey] )
                    shopCommentLikeList = [list objectAtIndex:0];
                else if ( [@"updatedShopCommentLikeList" isEqualToString:infoKey] )
                    shopCommentLikeList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [shopCommentLikeList count]; i++ )
                {
                    ShopCommentLike *shopCommentLike = [[ShopCommentLike alloc] initWithDictionaryValues:
                                                 [shopCommentLikeList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertShopCommentLike:shopCommentLike];
                    [shopCommentLike release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
}

-(void) updateMenuLikes
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedMenuLikeInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedMenuLikeList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        [[DataManager sharedDataManager] deleteMenuLikes:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"menuLikeLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"MENU_LIKE_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteMenuLikes:infoValue];
                
                if ( [@"deletedMenuLikeList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *menuLikeList = nil;
                
                if ( [@"newMenuLikeList" isEqualToString:infoKey] )
                    menuLikeList = [list objectAtIndex:0];
                else if ( [@"updatedShopLikeList" isEqualToString:infoKey] )
                    menuLikeList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [menuLikeList count]; i++ )
                {
                    MenuLike *menuLike = [[MenuLike alloc] initWithDictionaryValues:[menuLikeList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertMenuLike:menuLike];
                    [menuLike release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
}

-(void) updateMenuComments
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedMenuCommentInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedMenuCommentList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
        
        [[DataManager sharedDataManager] deleteMenuComments:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"menuCommentLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"MENU_COMMENT_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteMenuComments:infoValue];
                
                if ( [@"deletedMenuCommentList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *menuCommentList = nil;
                
                if ( [@"newMenuCommentList" isEqualToString:infoKey] )
                    menuCommentList = [list objectAtIndex:0];
                else if ( [@"updatedMenuCommentList" isEqualToString:infoKey] )
                    menuCommentList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [menuCommentList count]; i++ )
                {
                    MenuComment *menuComment = [[MenuComment alloc] initWithDictionaryValues:[menuCommentList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertMenuComment:menuComment];
                    [menuComment release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
}

-(void) updateMenuCommentLikes
{
    NSDictionary *info = [[responseString JSONValue] objectForKey:@"updatedMenuCommentLikeInfo"];
    NSArray *list = [[responseString JSONValue] objectForKey:@"updatedMenuCommentLikeList"];
    
    if ( [info isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *allKeys = [info allKeys];
        MetaInfo *metaInfo = nil;
    
        [[DataManager sharedDataManager] deleteMenuCommentLikes:@"-1"];
        
        for ( int i = 0; i < [allKeys count]; i++ )
        {
            NSString *infoKey = [allKeys objectAtIndex:i];
            NSString *infoValue = [info objectForKey:[allKeys objectAtIndex:i]];
            
            NSLog(@"%@ %@", infoKey, infoValue);
            
            if ( [infoValue isKindOfClass:[NSNull class]] )
                infoValue = @"";
            
            if ( [@"menuCommentLikeLastUpdateDate" isEqualToString:infoKey] )
            {
                metaInfo = [[MetaInfo alloc] init];
                metaInfo.name = @"MENU_COMMENT_LIKE_LAST_MODIFIED_DATE";
                metaInfo.value = infoValue;
            }
            else
            {
                [[DataManager sharedDataManager] deleteMenuCommentLikes:infoValue];
                
                if ( [@"deletedMenuCommentLikeList" isEqualToString:infoKey] )
                    continue;
                
                NSArray *menuCommentLikeList = nil;
                
                if ( [@"newMenuCommentLikeList" isEqualToString:infoKey] )
                    menuCommentLikeList = [list objectAtIndex:0];
                else if ( [@"updatedMenuCommentLikeList" isEqualToString:infoKey] )
                    menuCommentLikeList = [list objectAtIndex:1];                    
                
                for ( int i = 0; i < [menuCommentLikeList count]; i++ )
                {
                    MenuCommentLike *menuCommentLike = [[MenuCommentLike alloc] initWithDictionaryValues:
                                                        [menuCommentLikeList objectAtIndex:i]];
                    [[DataManager sharedDataManager] insertMenuCommentLike:menuCommentLike];
                    [menuCommentLike release];
                }
            }        
        }
        
        if ( metaInfo != nil )
        {
            [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
            [metaInfo release];
        }
    }
}

@end
