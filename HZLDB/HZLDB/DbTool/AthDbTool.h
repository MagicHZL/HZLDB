//
//  AthDbTool.h
//  Athena_iOS
//
//  Created by 郝忠良 on 2018/1/17.
//  Copyright © 2018年 haozhongliang. All rights reserved.
//

#import <Foundation/Foundation.h>


//文件管理者
#define ATFileManager  [NSFileManager defaultManager]


//缓存sql版本号
#define SqliteVersion @"SqliteVersion"
////设置Log输出模式  DEBUG  BETA
#ifdef DEBUG
#define ATLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define ATLog(...)
#endif

///拼接字符串
#define AthStrAppend(...)  [NSString stringWithFormat:__VA_ARGS__]

//UserDefult
#define AthUserDefaults  [NSUserDefaults standardUserDefaults]

//获取沙盒Document路径
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface AthDbTool : NSObject

//创建表的sql
+(NSString *)buildCreatSqlStrWithTable:(NSString*)tableName fields:(NSDictionary*)fields;
//查询表的sql
+(NSString *)buildSearchSqlWithTable:(NSString*)tableName where:(NSDictionary*)param;
//插入表的sql
+(NSString *)buildInsertSqlWithTable:(NSString*)tableName fields:(NSDictionary*)fields;
//删除表的sql
+(NSString*)buildDelectSqlWithTable:(NSString*)tableName where:(NSDictionary*)param;
//更新表的sql
+(NSString*)buildUpdateSqlWithTable:(NSString*)tableName fields:(NSDictionary*)fields where:(NSDictionary*)param;


//存储本地表的版本
+(void)saveSqliteVersion:(NSInteger)version;
//获取本地表版本
+(NSInteger)getSqliteVersion;

@end
