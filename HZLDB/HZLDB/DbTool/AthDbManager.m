//
//  AthDbManager.m
//  Athena_iOS
//
//  Created by 郝忠良 on 2018/1/17.
//  Copyright © 2018年 haozhongliang. All rights reserved.
//

#import "AthDbManager.h"
#import "AthDbTool.h"

@implementation AthDbManager{

    FMDatabaseQueue *_queueDb;
    NSDictionary *_tables;
}

+(instancetype)shareManager{
    
    static AthDbManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [AthDbManager new];
        [manager initSafeDB];
        
    });
    
    return manager;
    
}



-(void)initSafeDB{
    
    NSString *dbPath = [[self getDbpath] stringByAppendingPathComponent:@"chaoge.db"];
    
    _queueDb = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
//    [self judgeVersion];
    [self creatTable];
}


-(void)judgeVersion{
    
    //获取后台对应sql版本号 若版本号不对应则获取最新表结构
    
//    NSInteger version = [AthDbTool getSqliteVersion];
//
//    [AthDbTool saveSqliteVersion:1];//示例
//
//    [self creatOldCopy];
//
    
    
}

-(void)doSqlWithSeverString:(NSString*)severString{
    
//    NSString *sql = @"create table bulktest1 (id integer primary key autoincrement, x text);create table bulktest2 (id integer primary key autoincrement, y text)";
//    NSString *sql = @"create table bulktest1 (id integer primary key autoincrement, x text);"
//    "create table bulktest2 (id integer primary key autoincrement, y text);"
//    "create table bulktest3 (id integer primary key autoincrement, z text);"
//    "insert into bulktest1 (x) values ('XXX');"
//    "insert into bulktest2 (y) values ('YYY');"
//    "insert into bulktest3 (z) values ('ZZZ');";

    [self creatOldCopy];
    
    NSArray *sqlArrs = [severString componentsSeparatedByString:@";"];
    
    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db open];
        BOOL isSuccess = NO;
        for (NSString *subSql in sqlArrs) {
            
            if (subSql.length > 6) {
                
               isSuccess = [db executeUpdate:subSql];
                
                if (!isSuccess) {
                    
                    [self recoverResion];
                    
                    break;
                }
            }
            
        }
        
        if (isSuccess) {
            
            [AthDbTool saveSqliteVersion:1];
        }
        
        [db close];
        
    }];
    
    
}

-(void)creatTable{

    
    NSString *tablePath = [[NSBundle mainBundle] pathForResource:@"PublicDb.plist" ofType:nil];
    _tables = [NSDictionary dictionaryWithContentsOfFile:tablePath];
    
    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
            
        [db open];
        
        for (NSString *table in _tables) {
            
            if (![db tableExists:table]) {
                
                [db executeUpdate:[AthDbTool buildCreatSqlStrWithTable:table fields:_tables[table]]];
                
            };
            
        }
        
        
        [db close];
            
    }];
    
    
}


//由于测试  后期需要修改

-(void)searchData:(NSDictionary*)model resault:(void(^)(NSArray* datas))res table:(NSString*)tablename{

    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db open];
        
        NSMutableArray *dataArr = [NSMutableArray array];
        
        NSString *sql = [AthDbTool buildSearchSqlWithTable:tablename where:model];
        
        FMResultSet *set = [db executeQuery:sql];
        
        while (set.next) {
            
            NSMutableDictionary *subDic = [NSMutableDictionary dictionary];
            
            for (NSString *key in _tables[tablename]) {
                
                id value = [set stringForColumn:key];
                if (value ) {
                   [subDic setObject:value forKey:key];
                }
            }
            
            [dataArr addObject:subDic];
        }
        
        [db close];
        
        res([dataArr copy]);
        
    }];
    
}


-(void)insertDataWithModel:(id)model table:(NSString*)tablename where:(NSDictionary*)where{
    
    //多数据插入
    if ([model isKindOfClass:[NSArray class]]) {
        
        [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
            
            [db open];
            for (NSDictionary *dic in model) {
                
                if (!_tables[tablename]) {
                    
                    ATLog(@"不存在此表");
                    return ;
                    
                }
                    
                NSString   *sql = [AthDbTool buildInsertSqlWithTable:tablename fields:dic];

                BOOL isOK = [db executeUpdate:sql];
                if (isOK) {
                    ATLog(@"添加成功");
                }
                
            }
            
            [db close];
            
        }];
    
        return;
    }

#pragma - 待修改
    
    //单数据插入与更新
   
    BOOL isUpdate = NO;
    
    if (where.count>0) {
        
        isUpdate = [self existsModel:where table:tablename];
    }
    
    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
            
        [db open];
        
        if (!_tables[tablename]) {
            
            ATLog(@"不存在此表");
            return ;
            
        }
        NSString *sql;
        
        if (isUpdate) {
           
            sql = [AthDbTool buildUpdateSqlWithTable:tablename fields:((NSDictionary*)model)  where:where];
            
        }else{
            
            sql = [AthDbTool buildInsertSqlWithTable:tablename fields:((NSDictionary*)model)];
        }
   

        BOOL isOK = [db executeUpdate:sql];
        if (isOK) {
            ATLog(@"添加成功");
        }
        
            
        [db close];
            
    }];
    
    
}



-(void)deleteDataWithModel:(id)model table:(NSString*)tablename{
    

    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db open];
        
//        NSDictionary *dic = nil;
//        if (model) {
//            dic = @{@"personid":model};
//        }
        // 执行删除操作
        BOOL isOK = [db executeUpdate:[AthDbTool buildDelectSqlWithTable:tablename where:model]];
        if (isOK) {
            ATLog(@"删除成功");
        }

        [db close];
        
    }];
    
    
}

-(BOOL)existsModel:(id)model table:(NSString*)tableName {
    
    __block BOOL isExists = NO;
    
    [self searchData:model resault:^(NSArray *datas) {
        
        if (datas.count>0) {
            
            isExists = YES;
        }
        
    } table:tableName];
    
    return isExists;
    
}


-(NSString*)getDbpath{
    
    
    NSString *dbStr = @"Db";
   
    
    NSString *path = [kDocumentPath stringByAppendingPathComponent:dbStr];
    
    if (![ATFileManager fileExistsAtPath:path]) {
        
        [ATFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    return path;
    
}


-(void)recoverResion{
    
    NSString *oldPath = [[self getDbpath] stringByAppendingPathComponent:@"testOld.db"];
    
    NSString *dbPath = [[self getDbpath] stringByAppendingPathComponent:@"test.db"];
    
    if ([ATFileManager fileExistsAtPath:dbPath]) {
        
        [ATFileManager removeItemAtPath:dbPath error:nil];
    }
   
    
    BOOL issue = [ATFileManager copyItemAtPath:oldPath toPath:dbPath error:nil];
    
    
}

//老版本副本
-(void)creatOldCopy{
    
    NSString *dbPath = [[self getDbpath] stringByAppendingPathComponent:@"test.db"];
    NSString *oldPath = [[self getDbpath] stringByAppendingPathComponent:@"testOld.db"];
    if ([ATFileManager fileExistsAtPath:oldPath]) {
        
        [ATFileManager removeItemAtPath:oldPath error:nil];
    }
    
    [ATFileManager copyItemAtPath:dbPath toPath:oldPath error:nil];
    
}

-(void)dropTable:(NSString*)tableName{
    
    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db open];
        
        [db executeUpdate:[NSString stringWithFormat:@" DROP TABLE  %@",tableName]];
        
        [db close];
        
    }];
    
}

/***    ***/

/*
 是否拆开
 **/
-(NSDictionary*)getAllTableInfo{
  /*
   PRAGMA table_info(person)
   
   select name from sqlite_master where type='table' order by name;
    **/
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [_queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db open];
        
        FMResultSet *set = [db executeQuery:@"select name from sqlite_master where type='table' order by name"];
        
        while (set.next) {
            
            NSString *key = [set stringForColumn:@"name"];
            
            FMResultSet *subSet = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)",key]];
            
            NSMutableDictionary *subDic = [NSMutableDictionary dictionary];
            while (subSet.next) {
                
                NSString *subKey = [subSet stringForColumn:@"name"];
                NSString *value = [subSet stringForColumn:@"type"];
                [subDic setValue:value forKey:subKey];
            }
            
            [dic setValue:subDic forKey:key];
            
        }
        
        
        [db close];
        
    }];

    
    return dic;
    
}

/**
    拆分上一个方法
 */
-(NSArray*)getTableName:(FMDatabase*)db{
    
    NSMutableArray *names = [NSMutableArray array];
    
    FMResultSet *set = [db executeQuery:@"select name from sqlite_master where type='table' order by name"];
    
    while (set.next) {
        
        NSString *key = [set stringForColumn:@"name"];
        [names addObject:key];
        
    }
    
    return [names copy];
    
}


-(NSDictionary*)getTableInfo:(NSString*)tableName db:(FMDatabase*)db{
    
    NSMutableDictionary *subDic = [NSMutableDictionary dictionary];
    FMResultSet *subSet = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName]];
    
    while (subSet.next) {
        
        NSString *subKey = [subSet stringForColumn:@"name"];
        NSString *value = [subSet stringForColumn:@"type"];
        [subDic setValue:value forKey:subKey];
    }
    
    return [subDic copy];
}



@end
