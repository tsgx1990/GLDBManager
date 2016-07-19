//
//  Feed+ForDB.m
//  GLDBManager
//
//  Created by guanglong on 16/7/19.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "Feed+ForDB.h"

@implementation Feed (ForDB)

+ (NSArray *)concernedColumns
{
    return @[@"itemId", @"title", @"itemType", @"infooo", @"rsses"];
}

+ (NSArray *)conformDBProtocolColumns
{
    return @[@"infooo", @"rsses"];
}

+ (Class)innerClassForPropertyName:(NSString *)propertyName
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

- (NSString *)sqlCreatingTable
{
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     primary key(%@) \
                     )",
                     NSStringFromClass([self class]),
                     @"itemId",
                     @"title",
                     @"itemId"];
    return sql;
}

- (NSString *)sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@) values \
                     ('%@', '%@')",
                     NSStringFromClass([self class]),
                     @"itemId", @"title",
                     self.itemId, self.title];
    return sql;
}

+ (NSString *)keyAsSubtableForeignKey
{
    return @"itemId";
}

@end

@implementation Rss (ForDB)

+ (NSArray *)concernedColumns
{
    return @[@"rssId", @"title", @"content"];
}

+ (NSArray *)conformDBProtocolColumns
{
    return nil;
}

+ (Class)innerClassForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (NSString *)sqlCreatingTable
{
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     primary key(%@) \
                     CONSTRAINT %@ foreign key(%@) references %@(%@) on delete cascade on update cascade \
                     )",
                     NSStringFromClass([self class]),
                     @"rssId",
                     @"title",
                     @"content",
                     kDBForeignKey,
                     @"rssId",
                     @"Feed",
                     kDBForeignKey,
                     @"Feed",
                     @"itemId"];
    return sql;
}

- (NSString *)sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@) values \
                     ('%@', '%@', '%@')",
                     NSStringFromClass([self class]),
                     @"rssId", @"title", @"content",
                     self.rssId, self.title, self.content];
    return sql;
}

- (NSString*)sqlInsertingDataWithSuperModel:(Feed*)superModel
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@) values \
                     ('%@', '%@', '%@', '%@')",
                     NSStringFromClass([self class]),
                     kDBForeignKey, @"rssId", @"title", @"content",
                     superModel.itemId, self.rssId, self.title, self.content];
    return sql;
}

@end


@implementation Info (ForDB)

+ (NSArray *)concernedColumns
{
    return @[@"id", @"name", @"age", @"height"];
}

+ (NSArray *)conformDBProtocolColumns
{
    return nil;
}

+ (Class)innerClassForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (NSString *)sqlCreatingTable
{
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     %@        text, \
                     primary key(%@) \
                     CONSTRAINT %@ foreign key(%@) references %@(%@) on delete cascade on update cascade \
                     )",
                     NSStringFromClass([self class]),
                     @"id",
                     @"name",
                     @"age",
                     @"height",
                     kDBForeignKey,
                     @"id",
                     @"Feed",
                     kDBForeignKey,
                     @"Feed",
                     @"itemId"];
    return sql;
}

- (NSString *)sqlInsertingData
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@) values \
                     ('%lld', '%@', '%@', '%f')",
                     NSStringFromClass([self class]),
                     @"id", @"name", @"age", @"height",
                     self.id, self.name, self.age, self.height];
    return sql;
}

- (NSString *)sqlInsertingDataWithSuperModel:(Feed*)superModel
{
    NSString* sql = [NSString emptyStringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@, %@) values \
                     ('%@', '%lld', '%@', '%@', '%f')",
                     NSStringFromClass([self class]),
                     kDBForeignKey, @"id", @"name", @"age", @"height",
                     superModel.itemId, self.id, self.name, self.age, self.height];
    return sql;
}

@end
