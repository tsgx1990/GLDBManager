//
//  TTDBProtocol.h
//  DBManager
//
//  Created by guanglong on 16/7/18.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+SQLFormat.h"

@protocol TTDBProtocol <NSObject>

@required
+ (NSArray*)ttdb_concernedColumns; // 需要存储的字段

+ (NSArray*)ttdb_conformDBProtocolColumns; // 遵循TTDBProtocol的字段，包括数组属性

+ (Class)ttdb_innerClassForPropertyName:(NSString*)propertyName;

- (NSString*)ttdb_sqlCreatingTable; // 创建表的sql
- (NSString*)ttdb_sqlInsertingData; // 插入数据的sql


@optional

// 涉及到外键时，由childTable对应的model类实现
- (NSString*)ttdb_sqlInsertingDataWithSuperModel:(id<TTDBProtocol>)superModel;

// 由parentTable对应的model类实现
+ (NSArray*)ttdb_primaryKeys;

// 由childTable对应的model类实现
+ (NSArray*)ttdb_foreignKeys;

@end
