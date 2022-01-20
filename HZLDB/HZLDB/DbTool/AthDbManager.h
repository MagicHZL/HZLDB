//
//  AthDbManager.h
//  Athena_iOS
//
//  Created by 郝忠良 on 2018/1/17.
//  Copyright © 2018年 haozhongliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface AthDbManager : NSObject

+(instancetype)shareManager;


/**
 插入/更新
 model 支持多数据与单数据
 */
-(void)insertDataWithModel:(id)model table:(NSString*)tablename where:(NSDictionary*)where;

/**
 查询
 model 为需要查询的条件
 */
-(void)searchData:(NSDictionary*)model resault:(void(^)(NSArray* datas))res table:(NSString*)tablename;

/**
 删除
 model 为删除条件
 */
-(void)deleteDataWithModel:(id)model table:(NSString*)tablename;

/**判断是否存在某数据
 model 为查询条件
 */
-(BOOL)existsModel:(id)model table:(NSString*)tableName;

/**
 删除某表
 */
-(void)dropTable:(NSString*)tableName;

//执行后台返回sql 字符串
-(void)doSqlWithSeverString:(NSString*)severString;

//获取数据库所有表信息
-(NSDictionary*)getAllTableInfo;

@end
