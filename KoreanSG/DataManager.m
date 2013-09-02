//
//  DataManager.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"

static DataManager *DataManagerInstance;
static sqlite3 *database;

static NSString *DB_ENTIRE_LOCK = @"Entire_Lock";

@implementation DataManager

+(DataManager *) sharedDataManager
{
	@synchronized(self)
    {
		if (DataManagerInstance == NULL)
		{
			DataManagerInstance = [[DataManager alloc] init];
			            
			if ( sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK )
			{
				sqlite3_close(database);
				NSAssert(0, @"Failed to open database");
			}
			
			NSLog(@"database path:%@", [self dataFilePath]);
                        
            // Database migration.
            NSString *fromVersion = [DataManagerInstance metaInfoString:@"CLIENT_VERSION"];
            [DataManagerInstance migrateFrom:fromVersion to:[Constants getClientVersion]];
            
            // create tables.
            [DataManagerInstance createMetaInfoTable];
            [DataManagerInstance createKoreanShopTable];
            [DataManagerInstance createNewShopTable];
            [DataManagerInstance createMenuTable];
            [DataManagerInstance createFavoritesShopTable];
            [DataManagerInstance createShopLikeTable];
            [DataManagerInstance createShopCommentTable];
            [DataManagerInstance createShopCommentLikeTable];
            [DataManagerInstance createMenuLikeTable];
            [DataManagerInstance createMenuCommentTable];
            [DataManagerInstance createMenuCommentLikeTable];
            
            
            MetaInfo *metaInfo = [[MetaInfo alloc] init];
            metaInfo.name = @"CLIENT_VERSION";
            metaInfo.value = [Constants getClientVersion];
            [DataManagerInstance insertMetaInfo:metaInfo];
            [metaInfo release];
		}
    }	
	
	return DataManagerInstance;
}


-(void) migrateFrom:(NSString *) fromVersion to:(NSString *) toVersion
{
    if ( [fromVersion isEqualToString:@""] && [toVersion isEqualToString:@"1.2"] )
    {
        if ( [self existsKoreanShopTable] == NO ) return;
                
        [self deleteAllMetaInfo];
        [self deleteAllMenus];
        [self deleteAllShops];
        [self updateShopTable];
    }
}

+(NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSLog(@"documentsDirectory: %@", documentsDirectory );
	return [documentsDirectory stringByAppendingPathComponent:kDBFileName];
}


#pragma mark Shop Table methods

- (NSMutableArray *) shopListWithCategory:(NSString *) category
{
    /*
    if ( [self getAllShopsInsertedToDB] == NO )
        [self insertAllShopListIntoDBFromFile];
    */
    
    return [self shopListFromDBWithCategory:category];
}

- (void) insertAllShopListIntoDBFromFile
{
    NSString *shopListFile = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"Shops" ofType:@"txt"] 
                                                             encoding:NSUTF8StringEncoding 
                                                                error:nil];
    
    NSArray *shops = [shopListFile componentsSeparatedByString:@"\n"];
    
    for ( int i = 0; i < [shops count]; i++ )
    {
        NSString *shopInfo = [[shops objectAtIndex:i] 
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ( [shopInfo rangeOfString:@"--"].length > 0 || [shopInfo isEqualToString:@""]) 
            continue;
        
        NSArray *shopInfoArray = [shopInfo componentsSeparatedByString:@"|"];
        
        Shop *shop = [[Shop alloc] init];
        
        int offset = 0;
        
        if ( [shopInfoArray count] > offset )
            shop.seq = [[[shopInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        if ( [shopInfoArray count] > offset )
            shop.category = [[shopInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [shopInfoArray count] > offset )
            shop.shopName = [[shopInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [shopInfoArray count] > offset )
            shop.phone = [[shopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [shopInfoArray count] > offset )
            shop.mobile = [[shopInfoArray objectAtIndex:offset++] 
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [shopInfoArray count] > offset )
            shop.phone1 = [[shopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        
        if ( [shopInfoArray count] > offset )
            shop.phone2 = [[shopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];                
        if ( [shopInfoArray count] > offset )
            shop.address = [[shopInfoArray objectAtIndex:offset++] 
                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [shopInfoArray count] > offset )
            shop.longitude = [[[shopInfoArray objectAtIndex:offset++] 
                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
        if ( [shopInfoArray count] > offset )
            shop.latitude = [[[shopInfoArray objectAtIndex:offset++] 
                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
        if ( [shopInfoArray count] > offset )
            shop.email = [[shopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        
        if ( [shopInfoArray count] > offset )
            shop.homepage = [[shopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        

        offset = offset;
        
        [self insertKoreanShop:shop];    
        
//        [[TransactionManager sharedManager] addNewShop:shop];
        
        [shop release];
    }
    
    [self setAllShopsInsertedYES];
}

- (NSMutableArray *) shopListFromDBWithCategory:(NSString *) category
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:
                           @"SELECT S.*, CNT_LIKE, CNT_COMMENT\
                           FROM SHOP S\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE\
                           FROM SHOP_LIKE\
                           GROUP BY SHOP_NO ) SL ON S.SHOPSEQ=SL.SHOP_NO\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT\
                           FROM SHOP_COMMENT\
                           GROUP BY SHOP_NO) SC ON S.SHOPSEQ=SC.SHOP_NO\
                           WHERE S.CATEGORY='%@'\
                           ORDER BY CNT_LIKE DESC, CNT_COMMENT DESC,S.SHOPNAME", category];
        
        if ( category == nil || [category isEqualToString:@""] || [category isEqualToString:@"전체"] )
            query = @"SELECT S.*, CNT_LIKE, CNT_COMMENT\
            FROM SHOP S\
            LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE\
            FROM SHOP_LIKE\
            GROUP BY SHOP_NO ) SL ON S.SHOPSEQ=SL.SHOP_NO\
            LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT\
            FROM SHOP_COMMENT\
            GROUP BY SHOP_NO) SC ON S.SHOPSEQ=SC.SHOP_NO\
            ORDER BY CNT_LIKE DESC,CNT_COMMENT DESC,S.SHOPNAME";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SEQ = sqlite3_column_int( statement,columnIndex++ );
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *MOBILE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE1 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE2 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *ADDRESS = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LONGITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LATITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *EMAIL = (char *)sqlite3_column_text( statement,columnIndex++);
                char *HOMEPAGE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CATEGORY_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                columnIndex = columnIndex;
                
                Shop *shop = [[Shop alloc] init];
                shop.seq = SEQ;
                shop.category = [[NSString stringWithUTF8String:CATEGORY] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.shopName = [[NSString stringWithUTF8String:SHOPNAME] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.phone = [NSString stringWithUTF8String:PHONE];
                shop.mobile = [NSString stringWithUTF8String:MOBILE];
                shop.phone1 = [NSString stringWithUTF8String:PHONE1];
                shop.phone2 = [NSString stringWithUTF8String:PHONE2];
                shop.address = [[NSString stringWithUTF8String:ADDRESS] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.longitude = [[NSString stringWithUTF8String:LONGITUDE] doubleValue];
                shop.latitude = [[NSString stringWithUTF8String:LATITUDE] doubleValue];
                shop.email = [NSString stringWithUTF8String:EMAIL];
                shop.homepage = [NSString stringWithUTF8String:HOMEPAGE];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        shop.bShowPrice = YES;
                    else
                        shop.bShowPrice = NO;
                }
                else
                    shop.bShowPrice = YES;
                
                if ( CREATE_DATE != nil )
                    shop.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( UPDATE_DATE != nil )
                    shop.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( DELETE_DATE != nil )
                    shop.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( SHOPNAME_EN != nil )
                    shop.shopNameEn = [[NSString stringWithUTF8String:SHOPNAME_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( CATEGORY_EN != nil )
                    shop.categoryEn = [[NSString stringWithUTF8String:CATEGORY_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                shop.nLikes = CNT_LIKES;
                shop.nComments = CNT_COMMENTS;
                
                [list addObject:shop];
                [shop release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (NSMutableArray *) shopListFromDBWithNameList:(NSString *) nameList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:
                           @"SELECT S.*, CNT_LIKE, CNT_COMMENT\
                           FROM SHOP S\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE\
                           FROM SHOP_LIKE\
                           GROUP BY SHOP_NO ) SL ON S.SHOPSEQ=SL.SHOP_NO\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT\
                           FROM SHOP_COMMENT\
                           GROUP BY SHOP_NO) SC ON S.SHOPSEQ=SC.SHOP_NO\
                           WHERE S.SHOPNAME in (%@) \
                           ORDER BY S.SHOPNAME", nameList];
                
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SEQ = sqlite3_column_int( statement,columnIndex++ );
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *MOBILE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE1 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE2 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *ADDRESS = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LONGITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LATITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *EMAIL = (char *)sqlite3_column_text( statement,columnIndex++);
                char *HOMEPAGE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CATEGORY_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                columnIndex = columnIndex;
                
                Shop *shop = [[Shop alloc] init];
                shop.seq = SEQ;
                shop.category = [[NSString stringWithUTF8String:CATEGORY] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.shopName = [[NSString stringWithUTF8String:SHOPNAME] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.phone = [NSString stringWithUTF8String:PHONE];
                shop.mobile = [NSString stringWithUTF8String:MOBILE];
                shop.phone1 = [NSString stringWithUTF8String:PHONE1];
                shop.phone2 = [NSString stringWithUTF8String:PHONE2];
                shop.address = [[NSString stringWithUTF8String:ADDRESS] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.longitude = [[NSString stringWithUTF8String:LONGITUDE] doubleValue];
                shop.latitude = [[NSString stringWithUTF8String:LATITUDE] doubleValue];
                shop.email = [NSString stringWithUTF8String:EMAIL];
                shop.homepage = [NSString stringWithUTF8String:HOMEPAGE];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        shop.bShowPrice = YES;
                    else
                        shop.bShowPrice = NO;
                }
                else
                    shop.bShowPrice = YES;
                
                if ( CREATE_DATE != nil )
                    shop.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( UPDATE_DATE != nil )
                    shop.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( DELETE_DATE != nil )
                    shop.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( SHOPNAME_EN != nil )
                    shop.shopNameEn = [[NSString stringWithUTF8String:SHOPNAME_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( CATEGORY_EN != nil )
                    shop.categoryEn = [[NSString stringWithUTF8String:CATEGORY_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                shop.nLikes = CNT_LIKES;
                shop.nComments = CNT_COMMENTS;
                
                [list addObject:shop];
                [shop release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (Shop *) shopWithSeq:(int) seq
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT S.*, CNT_LIKE, CNT_COMMENT\
                           FROM SHOP S\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE\
                           FROM SHOP_LIKE\
                           GROUP BY SHOP_NO ) SL ON S.SHOPSEQ=SL.SHOP_NO\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT\
                           FROM SHOP_COMMENT\
                           GROUP BY SHOP_NO) SC ON S.SHOPSEQ=SC.SHOP_NO\
                           where S.shopseq='%d'", seq];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SEQ = sqlite3_column_int( statement,columnIndex++ );
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *MOBILE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE1 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE2 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *ADDRESS = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LONGITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LATITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *EMAIL = (char *)sqlite3_column_text( statement,columnIndex++);
                char *HOMEPAGE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CATEGORY_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                
                Shop *shop = [[[Shop alloc] init] autorelease];
                shop.seq = SEQ;
                shop.category = [[NSString stringWithUTF8String:CATEGORY] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.shopName = [[NSString stringWithUTF8String:SHOPNAME] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.phone = [NSString stringWithUTF8String:PHONE];
                shop.mobile = [NSString stringWithUTF8String:MOBILE];
                shop.phone1 = [NSString stringWithUTF8String:PHONE1];
                shop.phone2 = [NSString stringWithUTF8String:PHONE2];
                shop.address = [[NSString stringWithUTF8String:ADDRESS] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.longitude = [[NSString stringWithUTF8String:LONGITUDE] doubleValue];
                shop.latitude = [[NSString stringWithUTF8String:LATITUDE] doubleValue];
                shop.email = [NSString stringWithUTF8String:EMAIL];
                shop.homepage = [NSString stringWithUTF8String:HOMEPAGE];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        shop.bShowPrice = YES;
                    else
                        shop.bShowPrice = NO;
                }
                else
                    shop.bShowPrice = YES;
                
                if ( CREATE_DATE != nil )
                    shop.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( UPDATE_DATE != nil )
                    shop.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( DELETE_DATE != nil )
                    shop.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( SHOPNAME_EN != nil )
                    shop.shopNameEn = [[NSString stringWithUTF8String:SHOPNAME_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( CATEGORY_EN != nil )
                    shop.categoryEn = [[NSString stringWithUTF8String:CATEGORY_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                return shop;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return nil;   
    }
}

- (NSMutableArray *) categoryListWithCounts
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = @"select category, count(category) from shop group by category order by count(category) desc";
        
        sqlite3_stmt *statement;
        int totalCount = 0;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while ( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                int count = sqlite3_column_int( statement,columnIndex++ );
                
                totalCount += count;
                
                NSString *categoryString = [[NSString stringWithUTF8String:CATEGORY] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                categoryString = [categoryString stringByAppendingFormat:@"|%d", count];
                
                [list addObject:categoryString];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        [list insertObject:[NSString stringWithFormat:@"전체|%d", totalCount] atIndex:0];
        
        return list;   
    }
}

-(BOOL)createKoreanShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"create table if not exists SHOP\
        (\
        SHOPSEQ integer,\
        CATEGORY text,\
        SHOPNAME text,\
        PHONE text,\
        MOBILE text,\
        PHONE1 text,\
        PHONE2 text,\
        ADDRESS text,\
        LONGITUDE text,\
        LATITUDE text,\
        EMAIL text,\
        HOMEPAGE text,\
        IS_SHOW_PRICE text,\
        CREATE_DATE text,\
        UPDATE_DATE text,\
        DELETE_DATE text,\
        SHOPNAME_EN text,\
        CATEGORY_EN text\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"SHOP table is created successfully.");    
    }
	
	return YES;
}

- (BOOL) existsKoreanShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = @"SELECT name FROM sqlite_master WHERE type='table' AND name='SHOP'";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while ( sqlite3_step( statement ) == SQLITE_ROW )
            {
                return YES;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;
    }
}

-(int) insertKoreanShop:(Shop *)shop
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shop == nil )
            NSAssert( 0, @"shop is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               SHOP(SHOPSEQ,CATEGORY,SHOPNAME,PHONE,MOBILE,PHONE1,PHONE2,ADDRESS,LONGITUDE,LATITUDE,EMAIL,HOMEPAGE,\
                               CREATE_DATE, UPDATE_DATE, DELETE_DATE,SHOPNAME_EN, CATEGORY_EN) \
                               values(%d,'%@','%@','%@','%@','%@','%@','%@','%f','%f','%@','%@', '%@', '%@', '%@','%@','%@');",
                               shop.seq,
                               [shop.category stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.shopName stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.phone stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.mobile stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.phone1 stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.phone2 stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.address stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               shop.longitude, shop.latitude,
                               [shop.email stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.homepage stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.createDate stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.updateDate stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.deleteDate stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.shopNameEn stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [shop.categoryEn stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]
                               ];
        
        NSLog(@"insert shop: %@", shop );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(SHOP): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) updateShopPriceShowInfo:(NSString *) updateString
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( [[updateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
              isEqualToString:@""] )
        {
            sqlString = @"update SHOP set IS_SHOW_PRICE='Y'";
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"update SHOP set IS_SHOW_PRICE='N' where SHOPSEQ in (%@)",updateString];
        }
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }
        
        if ( [[updateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
              isEqualToString:@""] )
            return;
        
        sqlString = [NSString stringWithFormat:@"update SHOP set IS_SHOW_PRICE='Y' where SHOPSEQ not in (%@)",updateString];
        
        NSLog(@"%@", sqlString );
        
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

-(void) deleteShops:(NSString *) shopList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( shopList == nil || [[shopList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                 isEqualToString:@""] ||
            [shopList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from SHOP where SHOPSEQ in (%@)",shopList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

-(void) deleteAllShops
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        sqlString = [NSString stringWithFormat:@"delete from SHOP"];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

-(void) updateShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSMutableArray *sqlAr = [[NSMutableArray alloc] init];
        [sqlAr addObject:@"ALTER TABLE SHOP ADD COLUMN CREATE_DATE TEXT"];
        [sqlAr addObject:@"ALTER TABLE SHOP ADD COLUMN UPDATE_DATE TEXT"];
        [sqlAr addObject:@"ALTER TABLE SHOP ADD COLUMN DELETE_DATE TEXT"];
        [sqlAr addObject:@"ALTER TABLE SHOP ADD COLUMN SHOPNAME_EN TEXT"];
        [sqlAr addObject:@"ALTER TABLE SHOP ADD COLUMN CATEGORY_EN TEXT"];
        
        for ( int i = 0; i < [sqlAr count]; i++ )
        {
            NSString *sqlString = [sqlAr objectAtIndex:i];
            
            sqlite3_stmt *stmt;
            if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
            {
                NSLog(@"prepare is failed.");
            }
            
            int result =  sqlite3_step( stmt );
            
            if ( result != SQLITE_DONE )
            {
                NSAssert1(0, @"Error dropping table(SHOP): %s", errorMsg );
                break;
            }   
        }
        
        [sqlAr release];
    }
}

-(void) dropShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"drop table SHOP";
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error dropping table(SHOP): %s", errorMsg );
        }   
    }
}

#pragma mark New Shop Table methods

- (NSMutableArray *) newShopList
{
    /*
    if ( [self getNewShopsListInsertedToDB] == NO )
        [self insertNewShopListIntoDBFromFile];
    */
    return [self newShopListFromDB];
}

- (NSMutableArray *) newShopListFromDB
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = @"select A.*, CNT_LIKE, CNT_COMMENT\
        from shop A \
        inner join NEWSHOP B on A.SHOPSEQ=B.SHOPSEQ\
        left outer join (select SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE FROM SHOP_LIKE GROUP BY SHOP_NO ) SL ON B.SHOPSEQ=SL.SHOP_NO\
        LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT FROM SHOP_COMMENT GROUP BY SHOP_NO) SC ON B.SHOPSEQ=SC.SHOP_NO\
        ORDER BY CNT_LIKE DESC, CNT_COMMENT DESC";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SEQ = sqlite3_column_int( statement,columnIndex++ );
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *MOBILE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE1 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE2 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *ADDRESS = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LONGITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LATITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *EMAIL = (char *)sqlite3_column_text( statement,columnIndex++);
                char *HOMEPAGE = (char *)sqlite3_column_text( statement,columnIndex++);
                
                columnIndex += 6;
                
                int CNT_LIKE = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENT = sqlite3_column_int( statement,columnIndex++ );
                
                Shop *shop = [[Shop alloc] init];
                shop.seq = SEQ;
                shop.category = [[NSString stringWithUTF8String:CATEGORY] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.shopName = [[NSString stringWithUTF8String:SHOPNAME] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.phone = [NSString stringWithUTF8String:PHONE];
                shop.mobile = [NSString stringWithUTF8String:MOBILE];
                shop.phone1 = [NSString stringWithUTF8String:PHONE1];
                shop.phone2 = [NSString stringWithUTF8String:PHONE2];
                shop.address = [[NSString stringWithUTF8String:ADDRESS] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.longitude = [[NSString stringWithUTF8String:LONGITUDE] doubleValue];
                shop.latitude = [[NSString stringWithUTF8String:LATITUDE] doubleValue];
                shop.email = [NSString stringWithUTF8String:EMAIL];
                shop.homepage = [NSString stringWithUTF8String:HOMEPAGE];
                
                shop.nLikes = CNT_LIKE;
                shop.nComments = CNT_COMMENT;
                
                [list addObject:shop];
                [shop release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

-(BOOL)createNewShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"create table if not exists NEWSHOP\
        (\
        NEWSHOPSEQ integer primary key,\
        SHOPSEQ INTEGER,\
        EVENTYN text,\
        DATEFROM text,\
        DATETO text,\
        DESC text\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"NEWSHOP table is created successfully.");
        return YES;   
    }
}

- (void) insertNewShopListIntoDBFromFile
{
    NSString *newShopListFile = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"NewShops" ofType:@"txt"] 
                                                             encoding:NSUTF8StringEncoding 
                                                                error:nil];
    
    NSArray *newShops = [newShopListFile componentsSeparatedByString:@"\n"];
    
    for ( int i = 0; i < [newShops count]; i++ )
    {
        NSString *newShopInfo = [[newShops objectAtIndex:i] 
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ( [newShopInfo rangeOfString:@"--"].length > 0 || [newShopInfo isEqualToString:@""]) 
            continue;
        
        NSArray *newShopInfoArray = [newShopInfo componentsSeparatedByString:@"|"];
        
        NewShop *newShop = [[NewShop alloc] init];
        
        int offset = 0;
        
        if ( [newShopInfoArray count] > offset )
            newShop.newShopSeq = [[[newShopInfoArray objectAtIndex:offset++] 
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        if ( [newShopInfoArray count] > offset )
            newShop.shopSeq = [[[newShopInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        if ( [newShopInfoArray count] > offset )
            newShop.eventYN = [[newShopInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [newShopInfoArray count] > offset )
            newShop.dateFrom = [[newShopInfoArray objectAtIndex:offset++] 
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [newShopInfoArray count] > offset )
            newShop.dateTo = [[newShopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [newShopInfoArray count] > offset )
            newShop.desc = [[newShopInfoArray objectAtIndex:offset++] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        
        
        [self insertNewShop:newShop];
        [newShop release];
    }
    
    [self setNewShopsListInsertedToDBYES];
}

-(int) insertNewShop:(NewShop *)newShop
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( newShop == nil )
            NSAssert( 0, @"new shop is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               NEWSHOP(NEWSHOPSEQ,SHOPSEQ,EVENTYN,DATEFROM,DATETO,DESC ) \
                               values(%d,%d,'%@','%@','%@','%@');",
                               newShop.newShopSeq, newShop.shopSeq,
                               [newShop.eventYN stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [newShop.dateFrom stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [newShop.dateTo stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [newShop.desc stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]
                               ];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(NEWSHOP): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteNewShops:(NSString *) shopList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( shopList == nil || [[shopList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                 isEqualToString:@""] ||
            [shopList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from NEWSHOP where NEWSHOPSEQ in (%@)",shopList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }
    }
}

-(void) deleteAllNewShop
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        sqlString = [NSString stringWithFormat:@"delete from NEWSHOP"];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(NEWSHOP): %s", errorMsg );
        }   
    }
}

-(void) migrateNewShopList
{
    [self deleteAllNewShop];
    
    NewShop *newShop = [[NewShop alloc] init];
    newShop.newShopSeq = 1;
    newShop.shopSeq = 211;
 
    [self insertNewShop:newShop];
    
    newShop.newShopSeq = 2;
    newShop.shopSeq = 191;
    
    [self insertNewShop:newShop];
    
    newShop.newShopSeq = 3;
    newShop.shopSeq = 216;
    
    [self insertNewShop:newShop];
    
    [newShop release];
}

#pragma mark Favorites Shop Table methods


-(BOOL)createFavoritesShopTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"create table if not exists FAVORITESSHOP\
        (\
        SHOPSEQ INTEGER primary key,\
        DESC text\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"FAVORITESSHOP table is created successfully.");
        return YES;   
    }
}

- (BOOL) existsInFavorites:(Shop *)shop
{    
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"select s.* from shop s\
                           inner join favoritesshop f on s.shopseq=f.shopseq where s.shopseq='%d'", shop.seq];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {
                return YES;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

-(int) insertFavoritesShopTable:(Shop *)shop
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = [NSString stringWithFormat: @"insert or replace \
                               into FAVORITESSHOP(SHOPSEQ,DESC) values( %d,'%@');", shop.seq, shop.shopName];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(METAINFO): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}


-(BOOL) deleteFromFavorites:(Shop *)shop
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        if ( shop == nil )
            NSAssert( 0, @"shop is nil" );
        
        NSString *deleteSQL = [NSString stringWithFormat:
                               @"delete from FAVORITESSHOP where SHOPSEQ=%d", [shop seq]];
        
        NSLog( @"%@",deleteSQL );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [deleteSQL UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
            NSAssert1(0, @"Error deleting SCRIPT" , nil );
        
        return YES;   
    }
}

- (NSMutableArray *) favoriteShopList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select s.*, CNT_LIKE, CNT_COMMENT from shop s\
                           inner join favoritesshop f on s.shopseq=f.shopseq\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_LIKE FROM SHOP_LIKE \
                                            GROUP BY SHOP_NO ) SL ON S.SHOPSEQ=SL.SHOP_NO\
                           LEFT OUTER JOIN ( SELECT SHOP_NO, COUNT(SHOP_NO) AS CNT_COMMENT\
                                            FROM SHOP_COMMENT\
                                            GROUP BY SHOP_NO) SC ON S.SHOPSEQ=SC.SHOP_NO\
                           order by CNT_LIKE DESC, CNT_COMMENT DESC,s.shopname"];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SEQ = sqlite3_column_int( statement,columnIndex++ );
                char *CATEGORY = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *MOBILE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE1 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *PHONE2 = (char *)sqlite3_column_text( statement,columnIndex++);
                char *ADDRESS = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LONGITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *LATITUDE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *EMAIL = (char *)sqlite3_column_text( statement,columnIndex++);
                char *HOMEPAGE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CATEGORY_EN = (char *)sqlite3_column_text( statement,columnIndex++);
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                Shop *shop = [[Shop alloc] init];
                shop.seq = SEQ;
                shop.category = [[NSString stringWithUTF8String:CATEGORY] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.shopName = [[NSString stringWithUTF8String:SHOPNAME] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.phone = [NSString stringWithUTF8String:PHONE];
                shop.mobile = [NSString stringWithUTF8String:MOBILE];
                shop.phone1 = [NSString stringWithUTF8String:PHONE1];
                shop.phone2 = [NSString stringWithUTF8String:PHONE2];
                shop.address = [[NSString stringWithUTF8String:ADDRESS] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shop.longitude = [[NSString stringWithUTF8String:LONGITUDE] doubleValue];
                shop.latitude = [[NSString stringWithUTF8String:LATITUDE] doubleValue];
                shop.email = [NSString stringWithUTF8String:EMAIL];
                shop.homepage = [NSString stringWithUTF8String:HOMEPAGE];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        shop.bShowPrice = YES;
                    else
                        shop.bShowPrice = NO;
                }
                else
                    shop.bShowPrice = YES;
                
                if ( CREATE_DATE != nil )
                    shop.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( UPDATE_DATE != nil )
                    shop.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( DELETE_DATE != nil )
                    shop.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( SHOPNAME_EN != nil )
                    shop.shopNameEn = [[NSString stringWithUTF8String:SHOPNAME_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                if ( CATEGORY_EN != nil )
                    shop.categoryEn = [[NSString stringWithUTF8String:CATEGORY_EN] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                shop.nLikes = CNT_LIKES;
                shop.nComments = CNT_COMMENTS;
                
                [list addObject:shop];
                [shop release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

-(void) deleteAllFavoritesShops
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        sqlString = [NSString stringWithFormat:@"delete from favoritesshop"];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(FAVORITESSHOP): %s", errorMsg );
        }   
    }
}

- (NSMutableArray *) favoriteShopNameList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select DESC FROM favoritesshop"];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;                
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                [list addObject:[NSString stringWithUTF8String:SHOPNAME]];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;
    }
}

-(void) migrateFavoriteShopList
{
    NSMutableArray *list = [self favoriteShopNameList];
    
    if ( [list count] == 0 ) return;
    
    NSString *nameList = @"";
    
    for ( int i = 0; i < [list count]; i++ )
    {
        if ( i == 0 )
            nameList = [nameList stringByAppendingFormat:@"'%@'", [list objectAtIndex:i]];
        else
            nameList = [nameList stringByAppendingFormat:@",'%@'", [list objectAtIndex:i]];
    }
    
    [self deleteAllFavoritesShops];
    
    list = [self shopListFromDBWithNameList:nameList];
    
    for ( int i = 0; i < [list count]; i++ )
    {
        [self insertFavoritesShopTable:[list objectAtIndex:i]];
    }
}

#pragma mark -
#pragma mark Menu Table methods


-(BOOL)createMenuTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"create table if not exists MENU\
        (\
        MENUSEQ integer primary key,\
        SHOPSEQ integer,\
        MENUNAME text,\
        MENUUNIT text,\
        CURRENCY text,\
        PRICE integer,\
        MENUTYPE text\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"MENU table is created successfully.");
    }
    
    [self createMenuTableIndexes];
    return YES;
}

-(void) createMenuTableIndexes
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE INDEX if not exists menu_type_idx ON MENU (MENUNAME,MENUTYPE);";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating index: %s", errorMsg );
        }
        
        NSLog(@"MENU Type index is created successfully.");   
    }
}

-(int) insertMenu:(Menu *)menu
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menu == nil )
            NSAssert( 0, @"menu is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               MENU(MENUSEQ,SHOPSEQ,MENUNAME,MENUUNIT,CURRENCY,PRICE,MENUTYPE ) \
                               values(%d,'%d','%@','%@','%@','%f','%@');",
                               menu.menuSeq, menu.shopSeq,
                               [menu.menuName stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [menu.menuUnit stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [menu.currency stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               menu.price,
                               [menu.menuType stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString);
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(MENU): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );    
    }
}

-(void) insertMenuToDBFromFile
{
    // removed since client version 1.2
    
    /*
    NSMutableArray *menuList = nil;
    NSString* menuVersion = [self getMenuVersion];
    
    if ( [menuVersion isEqualToString:@""] || [menuVersion floatValue] < 1 )
    {
        menuList = [self menuListFromFile];
        
        for (Menu *menu in menuList) {
            
            [[TransactionManager sharedManager] addShopMenu:menu];
            [self insertMenu:menu];
        }
        
        MetaInfo* metaInfo = [[MetaInfo alloc] init];
        metaInfo.name = @"MENU_VERSION";
        metaInfo.value = @"1.0";
        metaInfo.desc = @"MENU_VERSION";
        [self insertMetaInfo:metaInfo];
        [metaInfo release];
    }
     */
}

- (NSMutableArray *) menuList:(int) shopSeq
{
    NSMutableArray *menuList = nil;
    
//    [self insertMenuToDBFromFile];
    
    menuList = [self menuListFromDB:shopSeq];
    return menuList;
}

- (NSMutableArray *) menuListFromFile
{
    NSMutableArray *menuList = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *menuListFile = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"txt"] 
                                                             encoding:NSUTF8StringEncoding 
                                                                error:nil];
    
    NSArray *menus = [menuListFile componentsSeparatedByString:@"\n"];
    
    for ( int i = 0; i < [menus count]; i++ )
    {
        NSString *menuInfo = [[menus objectAtIndex:i] 
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ( [menuInfo rangeOfString:@"--"].length > 0 || [menuInfo isEqualToString:@""]) 
            continue;
        
        NSArray *menuInfoArray = [menuInfo componentsSeparatedByString:@"|"];
        
        Menu *menu = [[Menu alloc] init];
        
        int offset = 0;
        
        if ( [menuInfoArray count] > offset )
            menu.menuSeq = [[[menuInfoArray objectAtIndex:offset++] 
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        if ( [menuInfoArray count] > offset )
            menu.shopSeq = [[[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        if ( [menuInfoArray count] > offset )
            menu.menuName = [[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [menuInfoArray count] > offset )
            menu.menuUnit = [[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];              
        if ( [menuInfoArray count] > offset )
            menu.currency = [[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( [menuInfoArray count] > offset )
            menu.price = [[[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        if ( [menuInfoArray count] > offset )
            menu.menuType = [[menuInfoArray objectAtIndex:offset++] 
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [menuList addObject:menu];
        
        NSLog(@"%@", menu );
        
        [menu release];
    }
    
    return menuList;
}

- (NSMutableArray *) menusWithName:(NSString *) menuName 
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select B.*, A.shopname, A.IS_SHOW_PRICE, CNT_LIKE,CNT_COMMENT\
                           from Shop A \
                           inner join Menu B on A.shopseq=B.shopseq \
                           left outer join (select MENU_NO, COUNT(MENU_NO) AS CNT_LIKE FROM MENU_LIKE GROUP BY MENU_NO) ML \
                                ON B.MENUSEQ=ML.MENU_NO\
                           left outer join (select MENU_NO, COUNT(MENU_NO) AS CNT_COMMENT FROM MENU_COMMENT GROUP BY MENU_NO) MC \
                                ON B.MENUSEQ=MC.MENU_NO\
                           where b.menuname='%@' order by CNT_LIKE DESC, CNT_COMMENT DESC, B.price", menuName];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int MENUSEQ = sqlite3_column_int( statement,columnIndex++ );
                int SHOPSEQ = sqlite3_column_int( statement,columnIndex++ );            
                char *MENUNAME = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *MENUUNIT = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CURRENCY = (char *)sqlite3_column_text( statement,columnIndex++);
                float PRICE = sqlite3_column_double( statement,columnIndex++ );            
                char *MENUTYPE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                Menu *menu = [[Menu alloc] init];
                menu.menuSeq = MENUSEQ;
                menu.shopSeq = SHOPSEQ;
                menu.shopName = [[NSString stringWithUTF8String:SHOPNAME] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.menuName = [[NSString stringWithUTF8String:MENUNAME] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.menuUnit = [[NSString stringWithUTF8String:MENUUNIT] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.currency = [[NSString stringWithUTF8String:CURRENCY] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.price = PRICE;
                menu.menuType = [[NSString stringWithUTF8String:MENUTYPE] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        menu.bShowPrice = YES;
                    else
                        menu.bShowPrice = NO;
                }
                else
                    menu.bShowPrice = YES;
                
                menu.nLikes = CNT_LIKES;
                menu.nComments = CNT_COMMENTS;
                
                [list addObject:menu];
                [menu release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (NSMutableArray *) menuListFromDB:(int) shopSeq
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select MENU.*,\
                           case when menutype='육류' then 0 when menutype='식사' then 1 \
                           when menutype='안주' then 2 when menutype='분식' then 3 \
                           when menutype='기타' then 4 when menutype='음료' then 5 \
                           when menutype='주류' then 6 else 7 end as menuOrder, CNT_LIKE, CNT_COMMENT\
                           from MENU \
                           left outer join (select MENU_NO, COUNT(MENU_NO) AS CNT_LIKE FROM MENU_LIKE GROUP BY MENU_NO) ML \
                           ON MENU.MENUSEQ=ML.MENU_NO\
                           left outer join \
                           (select MENU_NO, COUNT(MENU_NO) AS CNT_COMMENT FROM MENU_COMMENT GROUP BY MENU_NO) MC\
                           ON MENU.MENUSEQ=MC.MENU_NO\
                           where shopSeq=%d order by CNT_LIKE DESC, CNT_COMMENT DESC, menuOrder", shopSeq];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int MENUSEQ = sqlite3_column_int( statement,columnIndex++ );
                int SHOPSEQ = sqlite3_column_int( statement,columnIndex++ );            
                char *MENUNAME = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *MENUUNIT = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CURRENCY = (char *)sqlite3_column_text( statement,columnIndex++);
                float PRICE = sqlite3_column_double( statement,columnIndex++ );            
                char *MENUTYPE = (char *)sqlite3_column_text( statement,columnIndex++);
                
                columnIndex++;
                
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                Menu *menu = [[Menu alloc] init];
                menu.menuSeq = MENUSEQ;
                menu.shopSeq = SHOPSEQ;
                menu.menuName = [NSString stringWithUTF8String:MENUNAME];
                menu.menuUnit = [NSString stringWithUTF8String:MENUUNIT];
                menu.currency = [NSString stringWithUTF8String:CURRENCY];
                menu.price = PRICE;
                menu.menuType = [NSString stringWithUTF8String:MENUTYPE];
                
                menu.nLikes = CNT_LIKES;
                menu.nComments = CNT_COMMENTS;

                [list addObject:menu];
                [menu release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (NSMutableArray *) menuGroupList
{
    [self insertMenuToDBFromFile];
    
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = @"select menuname, count(menuname), menutype from menu group by menuname, menutype";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                char *MENUNAME = (char *)sqlite3_column_text( statement,columnIndex++ );
                int COUNT = sqlite3_column_int( statement,columnIndex++ );            
                char *MENUTYPE = (char *)sqlite3_column_text( statement,columnIndex++);
                
                MenuGroup *menuGroup = [[MenuGroup alloc] init];
                menuGroup.menuName = [[NSString stringWithUTF8String:MENUNAME] 
                                      stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuGroup.count = COUNT;
                menuGroup.menuType = [[NSString stringWithUTF8String:MENUTYPE] 
                                      stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                [list addObject:menuGroup];
                [menuGroup release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (NSMutableArray *) menuAndGroupList
{
    [self insertMenuToDBFromFile];
    
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = @"select menuname, count(menuname), menutype, \
        case when menutype='육류' then 0 when menutype='식사' then 1 \
        when menutype='안주' then 2 when menutype='분식' then 3 \
        when menutype='기타' then 4 when menutype='음료' then 5 \
        when menutype='주류' then 6 else 7 end as menuOrder\
        from menu \
        inner join SHOP S on S.SHOPSEQ=menu.SHOPSEQ\
        group by menuname\
        order by menuOrder, menuname";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                char *MENUNAME = (char *)sqlite3_column_text( statement,columnIndex++ );
                int COUNT = sqlite3_column_int( statement,columnIndex++ );            
                char *MENUTYPE = (char *)sqlite3_column_text( statement,columnIndex++);
                
                MenuGroup *menuGroup = nil;
                
                if ( COUNT == 1 )
                {
                    NSString *name = [[NSString stringWithUTF8String:MENUNAME]
                                      stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    Menu *menu = (Menu *) [[self menusWithName:name] objectAtIndex:0];
                    [list addObject:menu];
                }
                else
                {
                    menuGroup = [[MenuGroup alloc] init];
                    menuGroup.menuName = [[NSString stringWithUTF8String:MENUNAME] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    menuGroup.count = COUNT;
                    menuGroup.menuType = [[NSString stringWithUTF8String:MENUTYPE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    [list addObject:menuGroup];
                }
                
                [menuGroup release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

- (NSMutableArray *) menuListWithMenuGroup:(MenuGroup *) menuGroup
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select B.*, A.shopname, A.is_show_price, CNT_LIKE, CNT_COMMENT\
                           from Shop A \
                           inner join Menu B on A.shopseq=B.shopseq \
                           left outer join (select MENU_NO, COUNT(MENU_NO) AS CNT_LIKE FROM MENU_LIKE GROUP BY MENU_NO) ML \
                           ON B.MENUSEQ=ML.MENU_NO\
                           left outer join (select MENU_NO, COUNT(MENU_NO) AS CNT_COMMENT FROM MENU_COMMENT GROUP BY MENU_NO) MC \
                           ON B.MENUSEQ=MC.MENU_NO\
                           where b.menuname='%@' order by CNT_LIKE DESC, CNT_COMMENT DESC, B.price", menuGroup.menuName];
        
        if ( menuGroup == nil || [menuGroup.menuName isEqualToString:@""] )
            return nil;
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int MENUSEQ = sqlite3_column_int( statement,columnIndex++ );
                int SHOPSEQ = sqlite3_column_int( statement,columnIndex++ );            
                char *MENUNAME = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *MENUUNIT = (char *)sqlite3_column_text( statement,columnIndex++);
                char *CURRENCY = (char *)sqlite3_column_text( statement,columnIndex++);
                float PRICE = sqlite3_column_double( statement,columnIndex++ );            
                char *MENUTYPE = (char *)sqlite3_column_text( statement,columnIndex++);
                char *SHOPNAME = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_SHOW_PRICE = (char *)sqlite3_column_text( statement,columnIndex++);
                int CNT_LIKES = sqlite3_column_int( statement,columnIndex++ );
                int CNT_COMMENTS = sqlite3_column_int( statement,columnIndex++ );
                
                Menu *menu = [[Menu alloc] init];
                menu.menuSeq = MENUSEQ;
                menu.shopSeq = SHOPSEQ;
                menu.menuName = [[NSString stringWithUTF8String:MENUNAME] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.menuUnit = [[NSString stringWithUTF8String:MENUUNIT] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.currency = [[NSString stringWithUTF8String:CURRENCY] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.price = PRICE;
                menu.menuType = [[NSString stringWithUTF8String:MENUTYPE] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menu.shopName = [[NSString stringWithUTF8String:SHOPNAME] 
                                 stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                if ( IS_SHOW_PRICE != nil )
                {
                    NSString *showPrice = [[NSString stringWithUTF8String:IS_SHOW_PRICE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];;
                    
                    if ( [showPrice isEqualToString:@"Y"] )
                        menu.bShowPrice = YES;
                    else
                        menu.bShowPrice = NO;
                }
                else
                {
                    menu.bShowPrice = YES;
                }
                
                menu.nLikes = CNT_LIKES;
                menu.nComments = CNT_COMMENTS;
                
                [list addObject:menu];
                [menu release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

-(void) deleteMenus:(NSString *) menuList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( menuList == nil || [[menuList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                 isEqualToString:@""] ||
            [menuList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from MENU where MENUSEQ in (%@)",menuList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

-(void) deleteAllMenus
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        sqlString = [NSString stringWithFormat:@"delete from MENU"];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

#pragma mark MetaInfo Table methods

-(BOOL)createMetaInfoTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"create table if not exists METAINFO\
        (\
        NAME text primary key,\
        VALUE text,\
        DESC text\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database);
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"METAINFO table is created successfully.");
        return YES;   
    }
}

-(void) setMetaInfo:(NSString *)name value:(NSString *) value
{
    if ( value == nil || [value isKindOfClass:[NSNull class]] )
        value = @"";
    
    MetaInfo *metaInfo = [[MetaInfo alloc] init];
    metaInfo.name = name;
    metaInfo.value = value;
    [self insertMetaInfo:metaInfo];
    [metaInfo release];
}

-(int) insertMetaInfo:(MetaInfo *)metaInfo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( metaInfo == nil )
            NSAssert( 0, @"metaInfo is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert or replace into\
                               METAINFO(name,value,desc ) values('%@','%@','%@');",
                               [metaInfo.name stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [metaInfo.value stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"],
                               [metaInfo.desc stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]];
        
        NSLog( @"%@",sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(METAINFO): %s", errorMsg );
            return NO;
        }
        
        int insertRowId = sqlite3_last_insert_rowid( database );
        
        return insertRowId;   
    }
}

- (MetaInfo *) getMetaInfo:(NSString *) name
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"select * from METAINFO where name='%@'", name];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                char *NAME = (char *)sqlite3_column_text( statement,0);
                char *VALUE = (char *)sqlite3_column_text( statement,1);
                char *DESC = (char *)sqlite3_column_text( statement,2);
                
                MetaInfo *metaInfo = [[[MetaInfo alloc] init] autorelease];
                metaInfo.name = [[NSString stringWithUTF8String:NAME] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                metaInfo.value = [[NSString stringWithUTF8String:VALUE] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                metaInfo.desc = [[NSString stringWithUTF8String:DESC] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                return metaInfo;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return nil;   
    }
}

- (NSString *) metaInfoString:(NSString *)name
{
    MetaInfo *meta = [self getMetaInfo:name];
    if ( meta == nil )
        return @"";
    else
        return meta.value;
}

- (BOOL) getAllShopsInsertedToDB
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = @"select value from METAINFO where name='ALL_SHOPS_INSERTED'";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                char *VALUE = (char *)sqlite3_column_text( statement,0);
                return [[NSString stringWithUTF8String:VALUE] boolValue];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}
             
-(int) setAllShopsInsertedYES
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"insert or replace into METAINFO(name,value) values('ALL_SHOPS_INSERTED','YES');";
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(METAINFO): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

- (BOOL) getNewShopsListInsertedToDB
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = @"select value from METAINFO where name='NEW_SHOPS_INSERTED'";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                char *VALUE = (char *)sqlite3_column_text( statement,0);
                return [[NSString stringWithUTF8String:VALUE] boolValue];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

-(int) setNewShopsListInsertedToDBYES
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"insert or replace into METAINFO(name,value) values('NEW_SHOPS_INSERTED','YES');";
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(METAINFO): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(int) setAllShopsInsertedNO
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"insert or replace into METAINFO(name,value) values('ALL_SHOPS_INSERTED','NO');";
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(METAINFO): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

- (NSString *) getMenuVersion
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = @"select value from METAINFO where name='MENU_VERSION'";
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                char *VALUE = (char *)sqlite3_column_text( statement,0);
                return [NSString stringWithUTF8String:VALUE];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return @"";   
    }
}

-(void) deleteAllMetaInfo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        sqlString = [NSString stringWithFormat:@"delete from METAINFO"];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP): %s", errorMsg );
        }   
    }
}

#pragma mark Category methods

+(NSString *) categoryNoWithName:(NSString *) categoryName
{
    if ( [categoryName isEqualToString:@"식당"] )
        return @"1";
    else if ( [categoryName isEqualToString:@"컨설팅/법률상담/구인구직"] )
        return @"2";
    else if ( [categoryName isEqualToString:@"병원/클리닉"] )
        return @"3";
    else if ( [categoryName isEqualToString:@"학교/학원"] )
        return @"4";
    else if ( [categoryName isEqualToString:@"부동산"] )
        return @"5";
    else if ( [categoryName isEqualToString:@"해외이사"] )
        return @"6";
    else if ( [categoryName isEqualToString:@"여행사"] )
        return @"7";
    else if ( [categoryName isEqualToString:@"수퍼마켓/떡집/보조식품"] )
        return @"8";
    else if ( [categoryName isEqualToString:@"미용"] )
        return @"9";
    else if ( [categoryName isEqualToString:@"렌트카"] )
        return @"10";
    else if ( [categoryName isEqualToString:@"디자인/인테리어"] )
        return @"11";
    else if ( [categoryName isEqualToString:@"기타"] )
        return @"12";
    	
    return @"";
}

#pragma mark SHOP_LIKE TABLE methods

-(BOOL)createShopLikeTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE IF NOT EXISTS SHOP_LIKE\
        (\
        SHOP_LIKE_NO integer,\
        USER_NO INTEGER,\
        SHOP_NO INTEGER,\
        IS_USE text,\
        CREATE_DATE TEXT,\
        UPDATE_DATE TEXT,\
        DELETE_DATE TEXT\
        )";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"SHOP_LIKE table is created successfully.");
        return YES;   
    }
}

-(int) insertShopLike:(ShopLike *)shopLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shopLike == nil )
            NSAssert( 0, @"shopLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               SHOP_LIKE(SHOP_LIKE_NO, USER_NO, SHOP_NO, IS_USE, CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,'%@','%@','%@','%@');",
                               shopLike.shopLikeNo, shopLike.userNo, shopLike.shopNo, shopLike.isUse, 
                               shopLike.createDate, shopLike.updateDate, shopLike.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(SHOP_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(int) updateShopLike:(ShopLike *)shopLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shopLike == nil )
            NSAssert( 0, @"shopLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"update SHOP_LIKE set SHOP_LIKE_NO=%d, IS_USE='Y'\
                               where USER_NO=%d and SHOP_NO=%d and SHOP_LIKE_NO=-1",
                               shopLike.shopLikeNo, shopLike.userNo, shopLike.shopNo];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteShopLikes:(NSString *) shopLikeList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( shopLikeList == nil || [[shopLikeList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                     isEqualToString:@""] ||
            [shopLikeList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from SHOP_LIKE where SHOP_LIKE_NO in (%@)",shopLikeList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP_LIKE): %s", errorMsg );
        }   
    }
}

- (BOOL) doesUserLikeShop:(int) userNo shopNo:(int) shopNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(SHOP_LIKE_NO) FROM SHOP_LIKE\
                           WHERE SHOP_NO=%d AND USER_NO=%d", shopNo, userNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                int count = sqlite3_column_int( statement,0);
                
                if ( count > 0 )
                    return YES;
                else return NO;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

- (ShopLike *) shopLikeWithUserNo:(int) userNo shopNo:(int) shopNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM SHOP_LIKE\
                           WHERE SHOP_NO=%d AND USER_NO=%d", shopNo, userNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int SHOP_LIKE_NO = sqlite3_column_int( statement,columnIndex++ );
                int USER_NO = sqlite3_column_int( statement,columnIndex++ );
                int SHOP_NO = sqlite3_column_int( statement,columnIndex++ );
                char *IS_USE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );

                ShopLike *shopLike = [[[ShopLike alloc] init] autorelease];
                shopLike.shopLikeNo = SHOP_LIKE_NO;
                shopLike.userNo = USER_NO;
                shopLike.shopNo = SHOP_NO;
                shopLike.isUse = [[NSString stringWithUTF8String:IS_USE] 
                                  stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopLike.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopLike.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopLike.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                return shopLike;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return nil;   
    }
}

-(int) countShopLikes:(int) shopNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(USER_NO) FROM SHOP_LIKE\
                           WHERE SHOP_NO=%d", shopNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                int count = sqlite3_column_int( statement,0);
                
                return count;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

#pragma mark SHOP_COMMENT TABLE methods

-(BOOL)createShopCommentTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE IF NOT EXISTS SHOP_COMMENT\
        (\
        SHOP_COMMENT_NO	INTEGER,\
        USER_NO	INTEGER,\
        SHOP_NO	INTEGER,\
        COMMENT	TEXT,\
        IS_USE	TEXT,\
        CREATE_DATE	TEXT,\
        UPDATE_DATE	TEXT,\
        DELETE_DATE	TEXT\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"SHOP_COMMENT table is created successfully.");
        return YES;   
    }
}

- (NSMutableArray *) shopCommentsWithSeq:(int) shopSeq
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select * from SHOP_COMMENT where SHOP_NO=%d", shopSeq];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                int SHOP_COMMENT_NO = (int) sqlite3_column_int( statement, columnIndex++ );
                int USER_NO = (int) sqlite3_column_int( statement, columnIndex++ );
                int SHOP_NO = (int) sqlite3_column_int( statement, columnIndex++ );
                char *COMMENT = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *IS_USE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                
                ShopComment *shopComment = [[ShopComment alloc] init];
                shopComment.shopCommentNo = SHOP_COMMENT_NO;
                shopComment.userNo = USER_NO;
                shopComment.shopNo = SHOP_NO;
                shopComment.comment = [[NSString stringWithUTF8String:COMMENT] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopComment.isUse = [[NSString stringWithUTF8String:IS_USE] 
                                     stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopComment.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopComment.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                shopComment.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                [list addObject:shopComment];
                
                [shopComment release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

-(int) insertShopComment:(ShopComment *)shopComment
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shopComment == nil )
            NSAssert( 0, @"shopComment is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               SHOP_COMMENT(SHOP_COMMENT_NO, USER_NO, SHOP_NO, COMMENT, IS_USE, CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,'%@','%@','%@','%@','%@');",
                               shopComment.shopCommentNo, shopComment.userNo, shopComment.shopNo, shopComment.comment, shopComment.isUse, 
                               shopComment.createDate, shopComment.updateDate, shopComment.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(SHOP_COMMENT): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(int) updateShopComment:(ShopComment *)shopComment
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shopComment == nil )
            NSAssert( 0, @"shopComment is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"update SHOP_COMMENT set SHOP_COMMENT_NO=%d, IS_USE='Y'\
                               where USER_NO=%d and SHOP_NO=%d and SHOP_COMMENT_NO=-1",
                               shopComment.shopCommentNo, shopComment.userNo, shopComment.shopNo];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP_COMMENT): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteShopComments:(NSString *) shopCommentList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( shopCommentList == nil || [[shopCommentList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                        isEqualToString:@""] ||
            [shopCommentList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from SHOP_COMMENT where SHOP_COMMENT_NO in (%@)",shopCommentList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP_LIKE): %s", errorMsg );
        }   
    }
}

#pragma mark SHOP_COMMENT_LIKE TABLE methods

-(BOOL)createShopCommentLikeTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE  IF NOT EXISTS SHOP_COMMENT_LIKE\
        (\
        SHOP_COMMENT_LIKE_NO INTEGER,\
        USER_NO	INTEGER,\
        SHOP_NO	INTEGER,\
        SHOP_COMMENT_NO	INTEGER,\
        IS_USE	TEXT,\
        CREATE_DATE	TEXT,\
        UPDATE_DATE	TEXT,\
        DELETE_DATE	TEXT\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"SHOP_COMMENT_LIKE table is created successfully.");
        return YES;   
    }
}

-(int) insertShopCommentLike:(ShopCommentLike *)shopCommentLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( shopCommentLike == nil )
            NSAssert( 0, @"shopLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               SHOP_COMMENT_LIKE(SHOP_COMMENT_LIKE_NO, USER_NO, SHOP_NO, SHOP_COMMENT_NO, IS_USE,\
                               CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,%d,'%@','%@','%@','%@');",
                               shopCommentLike.shopCommentLikeNo, shopCommentLike.userNo, shopCommentLike.shopNo, 
                               shopCommentLike.shopCommentNo, shopCommentLike.isUse, 
                               shopCommentLike.createDate, shopCommentLike.updateDate, shopCommentLike.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(SHOP_COMMENT_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteShopCommentLikes:(NSString *) shopCommentLikeList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( shopCommentLikeList == nil || [[shopCommentLikeList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                            isEqualToString:@""] ||
            [shopCommentLikeList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from SHOP_COMMENT_LIKE where SHOP_COMMENT_LIKE_NO in (%@)",shopCommentLikeList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(SHOP_COMMENT_LIKE): %s", errorMsg );
        }   
    }
}

#pragma mark MENU_LIKE TABLE methods

-(BOOL)createMenuLikeTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE IF NOT EXISTS MENU_LIKE\
        (\
        MENU_LIKE_NO	INTEGER,\
        USER_NO	INTEGER,\
        MENU_NO	INTEGER,\
        IS_USE	TEXT,\
        CREATE_DATE	TEXT,\
        UPDATE_DATE	TEXT,\
        DELETE_DATE	TEXT\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"SHOP_LIKE table is created successfully.");
        return YES;   
    }
}

-(int) insertMenuLike:(MenuLike *)menuLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menuLike == nil )
            NSAssert( 0, @"shopLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               MENU_LIKE(MENU_LIKE_NO, USER_NO, MENU_NO, IS_USE, CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,'%@','%@','%@','%@');",
                               menuLike.menuLikeNo, menuLike.userNo, menuLike.menuNo, menuLike.isUse, 
                               menuLike.createDate, menuLike.updateDate, menuLike.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(MENU_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(int) updateMenuLike:(MenuLike *)menuLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menuLike == nil )
            NSAssert( 0, @"menuLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"update MENU_LIKE set MENU_LIKE_NO=%d, IS_USE='Y'\
                               where USER_NO=%d and MENU_NO=%d and MENU_LIKE_NO=-1",
                               menuLike.menuLikeNo, menuLike.userNo, menuLike.menuNo];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(MENU_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteMenuLikes:(NSString *) menuLikeList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( menuLikeList == nil || [[menuLikeList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                     isEqualToString:@""] ||
            [menuLikeList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from MENU_LIKE where MENU_LIKE_NO in (%@)",menuLikeList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(MENU_LIKE): %s", errorMsg );
        }   
    }
}

- (BOOL) doesUserLikeMenu:(int) userNo menuNo:(int) menuNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(USER_NO) FROM MENU_LIKE\
                           WHERE MENU_NO=%d AND USER_NO=%d", menuNo, userNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                int count = sqlite3_column_int( statement,0);
                
                if ( count > 0 )
                    return YES;
                else return NO;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

- (MenuLike *) menuLikeWithUserNo:(int) userNo shopNo:(int) menuNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM MENU_LIKE\
                           WHERE MENU_NO=%d AND USER_NO=%d", menuNo, userNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                
                int MENU_LIKE_NO = sqlite3_column_int( statement,columnIndex++ );
                int USER_NO = sqlite3_column_int( statement,columnIndex++ );
                int MENU_NO = sqlite3_column_int( statement,columnIndex++ );
                char *IS_USE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                
                MenuLike *menuLike = [[[MenuLike alloc] init] autorelease];
                menuLike.menuLikeNo = MENU_LIKE_NO;
                menuLike.userNo = USER_NO;
                menuLike.menuNo = MENU_NO;
                menuLike.isUse = [[NSString stringWithUTF8String:IS_USE] 
                                  stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuLike.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuLike.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuLike.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                       stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                return menuLike;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return nil;   
    }
}

-(int) countMenuLikes:(int) menuNo
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(USER_NO) FROM MENU_LIKE\
                           WHERE MENU_NO=%d", menuNo];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            if( sqlite3_step( statement ) == SQLITE_ROW )
            {	
                int count = sqlite3_column_int( statement,0);
                
                return count;
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return NO;   
    }
}

#pragma mark MENU_COMMENT TABLE methods

-(BOOL)createMenuCommentTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE IF NOT EXISTS MENU_COMMENT\
        (\
        MENU_COMMENT_NO	INTEGER,\
        USER_NO	INTEGER,\
        MENU_NO	INTEGER,\
        COMMENT	TEXT,\
        IS_USE	TEXT,\
        CREATE_DATE	TEXT,\
        UPDATE_DATE	TEXT,\
        DELETE_DATE	TEXT\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"MENU_COMMENT table is created successfully.");
        return YES;   
    }
}

- (NSMutableArray *) menuCommentsWithSeq:(int) menuSeq
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
        
        NSString *query = [NSString stringWithFormat:@"select * from MENU_COMMENT where MENU_NO=%d", menuSeq];
        
        sqlite3_stmt *statement;
        
        if ( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while( sqlite3_step( statement ) == SQLITE_ROW )
            {
                int columnIndex = 0;
                int MENU_COMMENT_NO = (int) sqlite3_column_int(statement, columnIndex++ );
                int USER_NO = (int) sqlite3_column_int(statement, columnIndex++ );
                int MENU_NO = (int) sqlite3_column_int(statement, columnIndex++ );
                char *COMMENT = (char *)sqlite3_column_text( statement,columnIndex++);
                char *IS_USE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *CREATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *UPDATE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                char *DELETE_DATE = (char *)sqlite3_column_text( statement,columnIndex++ );
                
                MenuComment *menuComment = [[MenuComment alloc] init];
                
                menuComment.menuCommentNo = MENU_COMMENT_NO;
                menuComment.userNo = USER_NO;
                menuComment.menuNo = MENU_NO;
                menuComment.comment = [[NSString stringWithUTF8String:COMMENT] 
                                     stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuComment.isUse = [[NSString stringWithUTF8String:IS_USE] 
                                     stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuComment.createDate = [[NSString stringWithUTF8String:CREATE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuComment.updateDate = [[NSString stringWithUTF8String:UPDATE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                menuComment.deleteDate = [[NSString stringWithUTF8String:DELETE_DATE] 
                                          stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                
                
                [list addObject:menuComment];
                
                [menuComment release];
            }
        }
        else {
            NSLog(@"fetching data error !!!!!");
        }
        
        return list;   
    }
}

-(int) insertMenuComment:(MenuComment *)menuComment
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menuComment == nil )
            NSAssert( 0, @"shopComment is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               MENU_COMMENT(MENU_COMMENT_NO, USER_NO, MENU_NO, COMMENT, IS_USE, CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,'%@','%@','%@','%@','%@');",
                               menuComment.menuCommentNo, menuComment.userNo, menuComment.menuNo, menuComment.comment, menuComment.isUse, 
                               menuComment.createDate, menuComment.updateDate, menuComment.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(MENU_COMMENT): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(int) updateMenuComment:(MenuComment *)menuComment
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menuComment == nil )
            NSAssert( 0, @"shopComment is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"update MENU_COMMENT set MENU_COMMENT_NO=%d, IS_USE='Y'\
                               where USER_NO=%d and MENU_NO=%d and MENU_COMMENT_NO=-1",
                               menuComment.menuCommentNo, menuComment.userNo, menuComment.menuNo];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(MENU_COMMENT): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteMenuComments:(NSString *) menuCommentList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( menuCommentList == nil || [[menuCommentList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                        isEqualToString:@""] ||
            [menuCommentList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from MENU_COMMENT where MENU_COMMENT_NO in (%@)",menuCommentList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(MENU_COMMENT): %s", errorMsg );
        }   
    }
}

#pragma mark MENU_COMMENT_LIKE TABLE methods

-(BOOL)createMenuCommentLikeTable
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg; 
        NSString *createSQL = 
        @"CREATE TABLE IF NOT EXISTS MENU_COMMENT_LIKE\
        (\
        MENU_COMMENT_LIKE_NO	INTEGER,\
        USER_NO	INTEGER,\
        MENU_NO	INTEGER,\
        MENU_COMMENT_NO	INTEGER,\
        IS_USE	TEXT,\
        CREATE_DATE	TEXT,\
        UPDATE_DATE	TEXT,\
        DELETE_DATE	TEXT\
        );";
        
        if (sqlite3_exec (database, [createSQL  UTF8String], 
                          NULL, NULL, &errorMsg) != SQLITE_OK) { 
            sqlite3_close(database); 
            NSAssert1( 0, @"Error creating table: %s", errorMsg );
            return NO;
        }
        
        NSLog(@"MENU_COMMENT_LIKE table is created successfully.");
        return YES;   
    }
}

-(int) insertMenuCommentLike:(MenuCommentLike *)menuCommentLike
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        if ( menuCommentLike == nil )
            NSAssert( 0, @"shopLike is nil" );
        
        NSString *sqlString = [NSString stringWithFormat:@"insert into\
                               MENU_COMMENT_LIKE(MENU_COMMENT_LIKE_NO, USER_NO, MENU_NO, MENU_COMMENT_NO, IS_USE,\
                               CREATE_DATE, UPDATE_DATE, DELETE_DATE) \
                               values(%d,%d,%d,%d,'%@','%@','%@','%@');",
                               menuCommentLike.menuCommentLikeNo, menuCommentLike.userNo, menuCommentLike.menuNo, 
                               menuCommentLike.menuCommentNo, menuCommentLike.isUse, 
                               menuCommentLike.createDate, menuCommentLike.updateDate, menuCommentLike.deleteDate];
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.[%@]", sqlString );
            return NO;
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error inserting table(MENU_COMMENT_LIKE): %s", errorMsg );
            return NO;
        }
        
        return sqlite3_last_insert_rowid( database );   
    }
}

-(void) deleteMenuCommentLikes:(NSString *) menuCommentLikeList
{
    @synchronized(DB_ENTIRE_LOCK)
    {
        char *errorMsg = nil;
        
        NSString *sqlString = @"";
        
        if ( menuCommentLikeList == nil || [[menuCommentLikeList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
                                            isEqualToString:@""] ||
            [menuCommentLikeList isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        sqlString = [NSString stringWithFormat:@"delete from MENU_COMMENT_LIKE where MENU_COMMENT_LIKE_NO in (%@)",menuCommentLikeList];
        
        NSLog(@"%@", sqlString );
        
        sqlite3_stmt *stmt;
        if ( sqlite3_prepare_v2( database, [sqlString UTF8String], -1, &stmt, nil) != SQLITE_OK )
        {
            NSLog(@"prepare is failed.");
        }
        
        if ( sqlite3_step( stmt ) != SQLITE_DONE )
        {
            NSAssert1(0, @"Error updating table(MENU_COMMENT_LIKE): %s", errorMsg );
        }   
    }
}

-(void) dealloc
{
	sqlite3_close(database);
	[super dealloc];
}
@end
