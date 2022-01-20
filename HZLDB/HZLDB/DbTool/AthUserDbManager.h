//
//  AthDbManager.h
//  Athena_iOS
//
//  Created by 郝忠良 on 2018/1/17.
//  Copyright © 2018年 haozhongliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"



//与用户相关缓存   和AthDbManager只是路径于参数（表结构）不同

@interface AthUserDbManager : NSObject

@property(nonatomic,copy)NSString *uid;

+(instancetype)shareManager;
-(void)initSafeDB:(NSString*)uid;
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
 查询
 model 为需要查询的条件
 file 排序字段 可以为多个 field1,field2
 adsc 升序 asc 降序 desc
 */

-(void)searchData:(NSDictionary*)model resault:(void(^)(NSArray* datas))res table:(NSString*)tablename orderFile:(NSString*)file adsc:(NSString*)adsc;
/**
 查询
 model 为需要查询的条件
 file 排序字段 可以为多个 field1,field2
 adsc 升序 asc 降序 desc
 limit 查询个数
 */

-(void)searchData:(NSDictionary*)model resault:(void(^)(NSArray* datas))res table:(NSString*)tablename orderFile:(NSString*)file adsc:(NSString*)adsc limit:(NSInteger)limit;
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

/**
 */

//执行后台返回sql 字符串
-(void)doSqlWithSeverString:(NSString*)severString;

//获取数据库所有表信息
-(NSDictionary*)getAllTableInfo;




@end
