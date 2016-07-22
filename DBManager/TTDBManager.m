//
//  TTDBManager.m
//  GLDBManager
//
//  Created by guanglong on 16/7/18.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "TTDBManager.h"
#import <objc/runtime.h>
#import "FMDB.h"


static TTDBManager* shareDBManager = nil;

@interface TTDBManager ()

@property (nonatomic, strong) FMDatabaseQueue* dbQueue;

@end

@implementation TTDBManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDBManager = [super allocWithZone:zone];
    });
    return shareDBManager;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDBManager = [[self alloc] init];
    });
    return shareDBManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbPath = [NSString stringWithFormat:@"%@/xxtt_content.db", docPath];
        NSLog(@"dbPath:%@", dbPath);
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

#pragma mark - - 增
- (BOOL)insertData:(id<TTDBProtocol>)data
{
    if (![data conformsToProtocol:@protocol(TTDBProtocol) ]) {
        return NO;
    }
    __block BOOL success = YES;
    // 关闭外键支持，否则无法完成关联表的插入操作
    [self openForeignKey:NO];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            if (![self saveData:data superModel:nil withDB:db]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
        @finally {
//            [db commit];
        }
    }];
    return success;
}

- (BOOL)insertDatas:(NSArray<id<TTDBProtocol>> *)datas
{
    if (!datas.count) {
        return NO;
    }
    __block BOOL success = YES;
    // 关闭外键支持，否则无法完成关联表的插入操作
    [self openForeignKey:NO];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            if (![self saveDatas:datas superModel:nil withDB:db]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
        @finally {
//            [db commit];
        }
    }];
    return success;
}

#pragma mark - - 删
- (BOOL)deleteFromTable:(NSString*)tableName where:(NSString *)condition
{
    if (!tableName.length || !condition.length) {
        return NO;
    }
    if (![self tableExists:tableName]) {
        return NO;
    }
    
    NSString* deleteSql = [NSString stringWithFormat:@"delete from %@", tableName];
    deleteSql = [self sqlByAddingCondition:condition toSql:deleteSql];
    
    __block BOOL success = YES;
    // 打开外键支持，对于关联表的删除操作，这一步是必须的，注意需要放在 inTransaction 外面
    [self openForeignKey:YES];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            if (![db executeStatements:deleteSql]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
    }];
    return success;
}

- (BOOL)deleteFromDataClass:(Class)dataClass where:(NSString *)condition
{
    if (![dataClass conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    else {
        return [self deleteFromTable:NSStringFromClass(dataClass) where:condition];
    }
}

- (BOOL)deleteFromData:(id<TTDBProtocol>)data where:(NSString *)condition
{
    if (![data conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    else {
        return [self deleteFromDataClass:[data class] where:condition];
    }
}

#pragma mark - - 改
- (BOOL)updateInTable:(NSString *)tableName withUpdateInfo:(id)updateInfo where:(NSString *)condition
{
    NSLog(@"tableName:%@, updateInfo:%@, condition:%@", tableName, updateInfo, condition);
    if (!tableName.length || !condition.length || !updateInfo) {
        NSLog(@"参数缺失");
        return NO;
    }
    if (![self tableExists:tableName]) {
        NSLog(@"表不存在");
        return NO;
    }
    
    NSMutableString* mParamsStr = [NSMutableString stringWithFormat:@"set "];
    if ([updateInfo isKindOfClass:[NSString class]]) {
        if ([updateInfo hasPrefix:mParamsStr]) {
            mParamsStr = [updateInfo mutableCopy];
        }
        else {
            [mParamsStr appendString:updateInfo];
        }
    }
    else if ([updateInfo isKindOfClass:[NSDictionary class]]) {
        NSMutableArray* mParamsArr = [NSMutableArray arrayWithCapacity:[updateInfo count]];
        NSArray* paramsKeys = [updateInfo allKeys];
        for (NSString* pKey in paramsKeys) {
            id pValue = [updateInfo valueForKey:pKey];
            [mParamsArr addObject:[NSString stringWithFormat:@"%@='%@'", pKey, pValue]];
        }
        [mParamsStr appendString:[mParamsArr componentsJoinedByString:@", "]];
    }
    else {
        NSString* error = [NSString stringWithFormat:@"%@ --> 参数类型错误", updateInfo];
//        NSAssert(0, error);
        NSLog(@"error:%@", error);
        return NO;
    }
    NSString* updateSql = [NSString stringWithFormat:@"update %@ %@", tableName, mParamsStr];
    updateSql = [self sqlByAddingCondition:condition toSql:updateSql];
    
    return [self updateWithSql:updateSql];
}

- (BOOL)updateInDataClass:(Class)dataClass withUpdateInfo:(id)updateInfo where:(NSString *)condition
{
    if (![dataClass conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    else {
        return [self updateInTable:NSStringFromClass(dataClass) withUpdateInfo:updateInfo where:condition];
    }
}

- (BOOL)updateInData:(id<TTDBProtocol>)data withUpdateInfo:(id)updateInfo where:(NSString *)condition
{
    if (![data conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    else {
        return [self updateInDataClass:[data class] withUpdateInfo:updateInfo where:condition];
    }
}

// 查
- (NSArray*)queryFromDataClass:(Class)dataClass concernedColumns:(NSArray *)concernedColumns where:(NSString *)condition
{
    if (![dataClass conformsToProtocol:@protocol(TTDBProtocol)]) {
        return nil;
    }
    
    NSString* tableName = NSStringFromClass(dataClass);
    if (![self tableExists:tableName]) {
        return nil;
    }
    
    NSInteger originConcernedCount = concernedColumns.count;
    if (originConcernedCount < 1) {
        concernedColumns = [dataClass ttdb_concernedColumns];
    }
    NSArray* unExistedColumns = nil;
    NSArray* existedColumns = [self existedColumnsInTable:tableName fromConcernedColumns:concernedColumns unexistedColumns:&unExistedColumns];
    
    // 如果有子表，则需要添加作为子表外键的column
    if ([dataClass respondsToSelector:@selector(ttdb_primaryKeys)]) {
        NSMutableSet* mSet = [NSMutableSet setWithArray:existedColumns];
        [mSet addObjectsFromArray:[dataClass ttdb_primaryKeys]];
        existedColumns = mSet.allObjects;
    }
    
    NSString* existedColumsStr = existedColumns.count && originConcernedCount>0 ? [existedColumns componentsJoinedByString:@","] : @"*";
    NSString* querySql = [NSString stringWithFormat:@"select %@ from %@", existedColumsStr, tableName];
    querySql = [self sqlByAddingCondition:condition toSql:querySql];
    
    NSArray* dbResults = [self queryWithSql:querySql];
    NSArray* modelArray = [self modelArrayFromDBResults:dbResults forModelClass:NSClassFromString(tableName)];
    
    if (unExistedColumns.count) {
        [self completeModelArray:modelArray withColumns:unExistedColumns];
    }
    return modelArray;
}

- (NSArray *)queryFromTable:(NSString *)tableName concernedColumns:(NSArray *)concernedColumns where:(NSString *)condition
{
    if (!tableName.length || ![self tableExists:tableName]) {
        return nil;
    }
    Class dataClass = NSClassFromString(tableName);
    return [self queryFromDataClass:dataClass concernedColumns:concernedColumns where:condition];
}

- (NSArray*)queryFromDataClass:(Class)dataClass where:(NSString *)condition
{
    return [self queryFromDataClass:dataClass concernedColumns:nil where:condition];
}

- (NSArray*)queryFromTable:(NSString *)tableName where:(NSString *)condition
{
    return [self queryFromTable:tableName concernedColumns:nil where:condition];
}

- (BOOL)tableExists:(NSString*)tableName
{
    __block BOOL isExisted = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isExisted = [db tableExists:tableName];
    }];
    return isExisted;
}

- (NSArray*)queryWithSql:(NSString*)querySql
{
    NSMutableArray* mDataArray = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet* resultSet = [db executeQuery:querySql];
        while ([resultSet next]) {
            [mDataArray addObject:[resultSet resultDictionary]];
        }
    }];
    return mDataArray.count ? mDataArray : nil;
}

- (BOOL)updateWithSql:(NSString*)updateSql
{
    __block BOOL success = YES;
    // 打开外键支持，对于关联表的更新操作，这一步是必须的，注意需要放在 inTransaction 外面
    [self openForeignKey:YES];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
//            NSString* updateSql = [NSString stringWithFormat:@"update %@ %@ %@", entity.tableName, params, condition];
            if (![db executeStatements:updateSql]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
    }];
    return success;
}

#pragma mark - - private

- (NSString*)sqlByAddingCondition:(NSString*)condition toSql:(NSString*)toSql
{
    if (!toSql.length) {
        return @"";
    }
    if (!condition.length) {
        return toSql;
    }
    
    NSString* finalSql = [toSql stringByAppendingFormat:@" %@", condition];
    return finalSql;
    
//    NSString* finalSql = nil;
//    if (!condition.length) {
//        finalSql = toSql;
//    }
//    else if ([condition hasPrefix:@"where"]) {
//        finalSql = [toSql stringByAppendingFormat:@" %@", condition];
//    }
//    else {
//        finalSql = [toSql stringByAppendingFormat:@" where %@", condition];
//    }
//    return finalSql;
}

- (void)completeModelArray:(NSArray*)modelArray withColumns:(NSArray*)columns
{
    if (!modelArray.count || !columns.count) {
        return;
    }
    
    for (NSObject<TTDBProtocol>* model in modelArray) {
        for (NSString* column in columns) {
            
            NSArray* conformDBColumns = [model.class ttdb_conformDBProtocolColumns];
            if (![conformDBColumns containsObject:column]) {
                continue;
            }
            
            Class propertyClass = [self propertyClassOfModel:model forPropertyName:column];
            if (!propertyClass) {
                continue;
            }
            
            if ([propertyClass isSubclassOfClass:[NSArray class]]) {
                
                Class innerClass = [model.class ttdb_innerClassForPropertyName:column];
                if (innerClass) {
                    NSArray* innerModels = [self innerModelsWithOuterModel:model andInnerClass:innerClass];
                    [model setValue:innerModels forKey:column];
                }
            }
            else if ([propertyClass conformsToProtocol:@protocol(TTDBProtocol)]) {
                NSArray* innerModels = [self innerModelsWithOuterModel:model andInnerClass:propertyClass];
                [model setValue:innerModels.firstObject forKey:column];
            }
            else  {
                // do nothing
            }
        }
    }
}

- (NSArray*)innerModelsWithOuterModel:(NSObject<TTDBProtocol>*)outerModel andInnerClass:(Class)innerClass
{
    NSArray* primaryKeys = [outerModel.class ttdb_primaryKeys];
    NSArray* foreignKeys = [innerClass ttdb_foreignKeys];
    assert(primaryKeys.count == foreignKeys.count);
    
    NSMutableArray* mConditions = [NSMutableArray arrayWithCapacity:primaryKeys.count];
    for (int i=0; i<primaryKeys.count; i++) {
        NSString* pKey = primaryKeys[i];
        NSString* fKey = foreignKeys[i];
        
        id valueOfPKey = [outerModel valueForKey:pKey];
        NSString* conditionStr = [NSString stringWithFormat:@"%@='%@'", fKey, valueOfPKey];
        [mConditions addObject:conditionStr];
    }
    
    NSString* totalCondition = [@"where " stringByAppendingString:[mConditions componentsJoinedByString:@" and "]];
    NSArray* innerModels = [self queryFromDataClass:innerClass where:totalCondition];
    return innerModels;
}

- (Class)propertyClassOfModel:(NSObject*)model forPropertyName:(NSString*)propertyName
{
    Class propertyClass = nil;
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString* name = [NSString stringWithFormat:@"%s", property_getName(property)];
        if ([propertyName isEqualToString:name]) {
            
            NSString* attrStr = [NSString stringWithFormat:@"%s", property_getAttributes(property)];
            NSLog(@"attrStr:%@", attrStr);
            NSArray* attrStrArr = [attrStr componentsSeparatedByString:@","];
            NSString* firstAttrStr = attrStrArr.firstObject;
            if ([firstAttrStr hasPrefix:@"T@\""]) {
                firstAttrStr = [firstAttrStr stringByReplacingOccurrencesOfString:@"T@\"" withString:@""];
                firstAttrStr = [firstAttrStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                NSLog(@"firstAttrStr:%@", firstAttrStr);
                propertyClass = NSClassFromString(firstAttrStr);
            }
            break;
        }
    }
    free(properties);
    return propertyClass;
}

// 将concernedColumns中的字段拆分成：tableName表中存在的并返回，和表中不存在的，存放在 *unexistedColumns 中
- (NSArray*)existedColumnsInTable:(NSString*)tableName fromConcernedColumns:(NSArray*)concernedColumns unexistedColumns:(NSArray**)unexistedColumns
{
    if (!concernedColumns.count) {
        *unexistedColumns = nil;
        return nil;
    }
    
    NSMutableArray* mExistedColumns = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* mUnexistedColumns = [NSMutableArray arrayWithCapacity:1];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        for (NSString* column in concernedColumns) {
            if ([db columnExists:column inTableWithName:tableName]) {
                [mExistedColumns addObject:column];
            }
            else {
                [mUnexistedColumns addObject:column];
            }
        }
    }];
    *unexistedColumns = mUnexistedColumns.count ? mUnexistedColumns : nil;
    return mExistedColumns.count ? mExistedColumns : nil;
}

- (NSArray*)modelArrayFromDBResults:(NSArray*)dbResults forModelClass:(Class)modelClass
{
    if (!dbResults.count) {
        return nil;
    }
    if (![modelClass conformsToProtocol:@protocol(TTDBProtocol)]) {
        return nil;
    }
    
    NSMutableArray* mModels = [NSMutableArray arrayWithCapacity:dbResults.count];
    for (NSDictionary* dict in dbResults) {
        
        NSObject* model = [[modelClass alloc] init];
        for (NSString* key in dict.allKeys) {
            
            if (key.length) {
                NSString* keyGetter0 = [key substringToIndex:1];
                NSString* keyGetter1 = [key substringFromIndex:1];
                NSString* keySetter = [NSString stringWithFormat:@"set%@%@:", keyGetter0.capitalizedString, keyGetter1];
                if ([model respondsToSelector:NSSelectorFromString(keySetter)]) {
                    [model setValue:dict[key] forKey:key];
                }
            }
        }
        [mModels addObject:model];
    }
    return mModels;
}

- (BOOL)saveDatas:(NSArray<id<TTDBProtocol>>*)datas superModel:(NSObject<TTDBProtocol>*)superModel withDB:(FMDatabase*)db
{
    for (NSObject<TTDBProtocol> *data in datas) {
        
        if ([data conformsToProtocol:@protocol(TTDBProtocol)]) {
            [self saveData:data superModel:superModel withDB:db];
        }
    }
    return YES;
}

- (BOOL)saveData:(NSObject<TTDBProtocol> *)data superModel:(NSObject<TTDBProtocol>*)superModel withDB:(FMDatabase*)db
{
    if (![data conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    
    // 检测conformDB字段的类型，并选择相应的存储方式
    NSArray* conformDBColumns = [[data class] ttdb_conformDBProtocolColumns];
    for (NSString* column in conformDBColumns) {
        
        id columnValue = [data valueForKey:column];
        if ([columnValue isKindOfClass:[NSArray class]]) {
            [self saveDatas:columnValue superModel:data withDB:db];
        }
        else if ([columnValue conformsToProtocol:@protocol(TTDBProtocol)]) {
            [self saveData:columnValue superModel:data withDB:db];
        }
        else {
            // do nothing
        }
    }
    
    // 建表
    if (![self createTableWithData:data withDB:db]) {
        return NO;
    }
    
    // 插入数据
    BOOL insertSucess = NO;
    if (superModel) {
        insertSucess = [db executeStatements:[data ttdb_sqlInsertingDataWithSuperModel:superModel]];
    }
    else {
        insertSucess = [db executeStatements:data.ttdb_sqlInsertingData];
    }
    return insertSucess;
}

- (BOOL)createTableWithData:(id<TTDBProtocol>)data withDB:(FMDatabase*)db
{
    if (![db tableExists:NSStringFromClass([data class])]) {
        if ([db executeStatements:data.ttdb_sqlCreatingTable]) {
            return [self addColumsIfNeededWithData:data withDB:db];
        }
        else {
            return NO;
        }
    }
    else {
        return [self addColumsIfNeededWithData:data withDB:db];
    }
}

- (BOOL)addColumsIfNeededWithData:(NSObject<TTDBProtocol>*)data withDB:(FMDatabase*)db
{
    if (![data conformsToProtocol:@protocol(TTDBProtocol)]) {
        return NO;
    }
    
    static NSMutableSet* mTableNameSet = nil;
    @synchronized([self class]) {
        
        if (!mTableNameSet) {
            mTableNameSet = [NSMutableSet setWithCapacity:6];
        }
        
        NSString* tableName = NSStringFromClass([data class]);
        if (![mTableNameSet containsObject:tableName]) {
            // 如果表存在，则判断表中是否有全部所需字段，如果没有则添加，只需要执行一次即可
            
            BOOL shouldAddToTableSet = YES;
            NSMutableSet* allConcernedColumns = [NSMutableSet setWithArray:[[data class] ttdb_concernedColumns]];
            // 判断为关联表子表，则添加外键字段
            if ([data.class respondsToSelector:@selector(ttdb_foreignKeys)]) {
                [allConcernedColumns addObjectsFromArray:[data.class ttdb_foreignKeys]];
            }
            NSSet* allConformDBColumns = [NSSet setWithArray:[[data class] ttdb_conformDBProtocolColumns]];
            
            for (NSString* columnStr in allConcernedColumns) {
                
                if (![allConformDBColumns containsObject:columnStr]) {
                    
                    if (![db columnExists:columnStr inTableWithName:tableName]) {
                        NSString* alterAddSql = [NSString stringWithFormat:@"alter table %@ add %@ text default ''", tableName, columnStr];
                        if (![db executeStatements:alterAddSql]) {
                            shouldAddToTableSet = NO;
                        }
                    }
                }
            }
            
            if (shouldAddToTableSet) {
                [mTableNameSet addObject:tableName];
            }
        }
    }
    return YES;
}

- (BOOL)openForeignKey:(BOOL)open
{
    __block BOOL success = YES;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeStatements:[NSString stringWithFormat:@"PRAGMA foreign_keys=%i", (open ? 1:0)]];
    }];
    return success;
}


@end
