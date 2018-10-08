//
//  BitShareCoordinator.m
//  cybexMobile
//
//  Created by koofrank on 2018/4/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BitShareCoordinator.h"

#include "wallet_lib.hpp"

@implementation BitShareCoordinator
  
+ (NSString *)getUserKeys:(NSString *)username password:(NSString *)password {
  string keys = get_user_key([username UTF8String], [password UTF8String]);
  
  NSString *result = @(keys.c_str());
  
  return result;
}
  
+ (NSString *)getLimitOrder:(int)block_num block_id:(NSString *)block_id
                 expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                    user_id:(int)user_id order_expiration:(NSTimeInterval)order_expiration
                   asset_id:(int)asset_id amount:(int64_t)amount receive_asset_id:(int)receive_asset_id
             receive_amount:(int64_t)receive_amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount {
  string jsonString = limit_order_create(block_num, [block_id UTF8String], expiration, [chain_id UTF8String], user_id, order_expiration, asset_id, amount, receive_asset_id, receive_amount, 0, fee_amount, fee_id);
  
  return @(jsonString.c_str());
}
  
+ (NSString *)getLimitOrderOperation:(int)user_id expiration:(NSTimeInterval)expiration asset_id:(int)asset_id amount:(int64_t)amount receive_asset_id:(int)receive_asset_id receive_amount:(int64_t)receive_amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount {
  string jsonString= get_limit_order_create_json(user_id, expiration, asset_id, amount, receive_asset_id, receive_amount, 0, fee_amount, fee_id);
  return @(jsonString.c_str());
}
  
+ (NSString *)cancelLimitOrder:(int)block_num block_id:(NSString *)block_id
                    expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                       user_id:(int)user_id order_id:(int)order_id
                        fee_id:(int)fee_id fee_amount:(int64_t)fee_amount {
  string jsonString = cancel_order(block_num, [block_id UTF8String], expiration, [chain_id UTF8String], order_id, user_id, fee_amount, fee_id);
  return @(jsonString.c_str());
}
  
+ (NSString *)cancelLimitOrderOperation:(int)order_id user_id:(int)user_id fee_id:(int)fee_id fee_amount:(int64_t)fee_amount {
  string jsonString = get_cancel_order_json(order_id, user_id, fee_amount, fee_id);
  return @(jsonString.c_str());
}
  
+ (NSString *)getTransaction:(int)block_num block_id:(NSString *)block_id
                  expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                from_user_id:(int)from_user_id to_user_id:(int)to_user_id
                    asset_id:(int)asset_id receive_asset_id:(int)receive_asset_id
                      amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key {
  string jsonString = transfer(block_num, [block_id UTF8String], expiration, [chain_id UTF8String], from_user_id, to_user_id, amount, asset_id, fee_amount, fee_id, [memo UTF8String], [from_memo_key UTF8String], [to_memo_key UTF8String]);
  
  return @(jsonString.c_str());
}
  
+ (NSString *)getTransterOperation:(int)from_user_id to_user_id:(int)to_user_id asset_id:(int)asset_id amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key {
  string jsonString = get_transfer_op_json(from_user_id, to_user_id, amount, asset_id, fee_amount, fee_id, [memo UTF8String], [from_memo_key UTF8String], [to_memo_key UTF8String]);
  
  return @(jsonString.c_str());
}
  
+ (void)resetDefaultPublicKey:(NSString *)str {
  set_default_public_key([str UTF8String]);
}
  
+ (void)cancelUserKey {
  clear_user_key();
}
  
  
+ (NSString *)getRecodeLoginOperation:(NSString *)accountName asset:(NSString *)asset fundType:(NSString *)fundType size:(int)size offset:(int)offset expiration:(int)expiration {
    
  string jsonString = cybex_gateway_query([accountName UTF8String], [asset UTF8String], [fundType UTF8String], size, offset, expiration);
  return @(jsonString.c_str());
}
  
+ (NSString *)getMemo:(NSString *)memo {
  string jsonString = decrypt_memo_data([memo UTF8String]);
  return @(jsonString.c_str());
}
  
  @end
