//
//  AthDbTool.m
//  Athena_iOS
//
//  Created by 郝忠良 on 2018/1/17.
//  Copyright © 2018年 haozhongliang. All rights reserved.
//

#import "AthDbTool.h"

@implementation AthDbTool

+(NSString *)buildCreatSqlStrWithTable:(NSString*)tablename fields:(NSDictionary*)fields{
    
    //CREATE TABLE Test(testid INTEGER PRIMARY KEY NOT NULL,name text, age text)
    
    NSMutableString *sql = [NSMutableString string];
    
    [sql appendFormat:@"CREATE TABLE %@ ",tablename];
    
    [sql appendFormat:@"(%@id INTEGER PRIMARY KEY NOT NULL ",tablename];
    
    for (NSString *key in fields) {
        
        [sql appendFormat:@", %@ %@",key,fields[key]];
        
    }
    
    [sql appendString:@")"];
    
    return [sql copy];
}


+(NSString *)buildSearchSqlWithTable:(NSString*)tableName where:(NSDictionary*)param{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@",tableName];
    
    if (param) {
        
        [sql appendString:@" where "];
        for (NSString *field in param) {
            
            [sql appendFormat:@"%@ = '%@' and ",field,param[field]];
            
        }
        [sql deleteCharactersInRange:NSMakeRange(sql.length - 4, 4)];
    }
    
    return sql;
    
}


+(NSString *)buildInsertSqlWithTable:(NSString *)tableName fields:(NSDictionary *)fields{
    
    // insert into Test (name ,age) values (?, ?)
    
    NSMutableString *sql = [NSMutableString string];
    NSMutableString *valuesStr = [NSMutableString stringWithString:@" values ( "];
    
    [sql appendFormat:@"insert into %@ (",tableName];
    
    
    for (NSString *key in fields) {
        
        /*测试用  -----*/
//        if ([key rangeOfString:@"id"].location !=NSNotFound || [fields[key] isKindOfClass:[NSNull class]]) {
//            continue;
//        }
        [sql appendFormat:@" %@ ,",key];
        [valuesStr appendFormat:@" '%@' ,",fields[key]];
        
    }
    
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [valuesStr deleteCharactersInRange:NSMakeRange(valuesStr.length - 1, 1)];
    
    [sql appendString:@" )"];
    [valuesStr appendString:@" )"];
    
    [sql appendString:valuesStr];
    
    return [sql copy];
    
}

+(NSString*)buildDelectSqlWithTable:(NSString*)tableName where:(NSDictionary*)param{
    
    //delete from Test where name = ?
    
    NSMutableString *sql = [NSMutableString stringWithString:@"delete from "];
    
    [sql appendString:tableName];
    
    if (!param) {
        
        return sql;
    }
    
    [sql appendString:@" where "];
    
    for (NSString *field in param) {
        
        [sql appendFormat:@"%@ = '%@' and ",field,param[field]];
    }
    
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 4, 4)];
    
    return sql;
}

+(NSString *)buildUpdateSqlWithTable:(NSString *)tableName fields:(NSDictionary *)fields where:(NSDictionary *)param{
    
    //update ItemsList set currentAnswer = ?, isRight = ? where questionid = ? and item_ID = ?
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set ",tableName];
    
    for (NSString *field in fields) {
        
        [sql appendFormat:@" %@ = '%@' ," ,field,fields[field]];
        
    }
    
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    
    [sql  appendString:@" where "];
    
    for (NSString *field in param) {
        
        [sql appendFormat:@" %@ = '%@' and",field,param[field]];
        
    }
    
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 3, 3)];
    
    return sql;
}


+(void)saveSqliteVersion:(NSInteger)version{
    
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:SqliteVersion];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+(NSInteger)getSqliteVersion{
    
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:SqliteVersion];
    
}



@end
