//
//  Feed+ForDB.m
//  GLDBManager
//
//  Created by guanglong on 16/7/19.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "Feed+ForDB.h"

@implementation Feed (ForDB)

+ (NSArray *)ttdb_concernedColumns
{
    return @[@"id", @"itemId", @"title", @"itemType", @"infooo", @"rsses"];
}

+ (NSArray *)ttdb_conformDBProtocolColumns
{
    return @[@"infooo", @"rsses"];
}

+ (Class)ttdb_innerClassForPropertyName:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"infooo"]) {
        return [Info class];
    }
    else if ([propertyName isEqualToString:@"rsses"]) {
        return [Rss class];
    }
    else {
        return nil;
    }
}

- (NSString *)ttdb_sqlCreatingTable
{
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        integer, \
                     %@        integer, \
                     %@        text, \
                     primary key(%@, %@) \
                     )",
                     NSStringFromClass([self class]),
                     @"id",
                     @"itemId",
                     @"title",
                     @"itemId", @"id"];
    return sql;
}

- (NSString *)ttdb_sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@) values \
                     ('%@', '%@', '%@')",
                     NSStringFromClass([self class]),
                     @"itemId", @"title", @"id",
                     self.itemId, self.title, self.id];
    return sql;
}

+ (NSArray *)ttdb_primaryKeys
{
    return @[@"itemId", @"id"];
}

@end

@implementation Rss (ForDB)

+ (NSArray *)ttdb_concernedColumns
{
    return @[@"rssId", @"title", @"content"];
}

+ (NSArray *)ttdb_conformDBProtocolColumns
{
    return nil;
}

+ (Class)ttdb_innerClassForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (NSString *)ttdb_sqlCreatingTable
{
    NSString* foreignKey0 = [self.class ttdb_foreignKeys][0];
    NSString* foreignKey1 = [self.class ttdb_foreignKeys][1];
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        integer, %@        integer, \
                     primary key(%@) \
                     CONSTRAINT %@ foreign key(%@, %@) references %@(%@, %@) on delete cascade on update cascade \
                     )",
                     NSStringFromClass([self class]),
                     @"rssId",
                     @"title",
                     @"content",
                     foreignKey0, foreignKey1,
                     @"rssId",
                     @"Feed",
                     foreignKey0, foreignKey1,
                     @"Feed",
                     @"itemId", @"id"];
    return sql;
}

- (NSString *)ttdb_sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@) values \
                     ('%@', '%@', '%@')",
                     NSStringFromClass([self class]),
                     @"rssId", @"title", @"content",
                     self.rssId, self.title, self.content];
    return sql;
}

- (NSString*)ttdb_sqlInsertingDataWithSuperModel:(Feed*)superModel
{
    NSString* foreignKey0 = [self.class ttdb_foreignKeys][0];
    NSString* foreignKey1 = [self.class ttdb_foreignKeys][1];
    
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@, %@) values \
                     ('%@', '%@', '%@', '%@', '%@')",
                     NSStringFromClass([self class]),
                     foreignKey0, foreignKey1, @"rssId", @"title", @"content",
                     superModel.itemId, superModel.id, self.rssId, self.title, self.content];
    return sql;
}

+ (NSArray *)ttdb_foreignKeys
{
    return @[@"ttdb_Feed_itemId", @"ttdb_Feed_id"];
}

@end


@implementation Info (ForDB)

+ (NSArray *)ttdb_concernedColumns
{
    return @[@"id", @"name", @"age", @"height"];
}

+ (NSArray *)ttdb_conformDBProtocolColumns
{
    return nil;
}

+ (Class)ttdb_innerClassForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (NSString *)ttdb_sqlCreatingTable
{
    NSString* foreignKey0 = [self.class ttdb_foreignKeys][0];
    NSString* foreignKey1 = [self.class ttdb_foreignKeys][1];
    
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        integer, %@        integer, \
                     primary key(%@) \
                     CONSTRAINT %@ foreign key(%@, %@) references %@(%@, %@) on delete cascade on update cascade \
                     )",
                     NSStringFromClass([self class]),
                     @"id",
                     @"name",
                     @"age",
                     @"height",
                     foreignKey0, foreignKey1,
                     @"id",
                     @"Feed",
                     foreignKey0, foreignKey1,
                     @"Feed",
                     @"itemId", @"id"];
    return sql;
}

- (NSString *)ttdb_sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@) values \
                     ('%lld', '%@', '%@', '%f')",
                     NSStringFromClass([self class]),
                     @"id", @"name", @"age", @"height",
                     self.id, self.name, self.age, self.height];
    return sql;
}

- (NSString *)ttdb_sqlInsertingDataWithSuperModel:(Feed*)superModel
{
    NSString* foreignKey0 = [self.class ttdb_foreignKeys][0];
    NSString* foreignKey1 = [self.class ttdb_foreignKeys][1];
    
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@, %@, %@) values \
                     ('%@', '%@', '%lld', '%@', '%@', '%f')",
                     NSStringFromClass([self class]),
                     foreignKey0, foreignKey1, @"id", @"name", @"age", @"height",
                     superModel.itemId, superModel.id, self.id, self.name, self.age, self.height];
    return sql;
}

+ (NSArray *)ttdb_foreignKeys
{
    return @[@"ttdb_Feed_itemId", @"ttdb_Feed_id"];
}

@end
