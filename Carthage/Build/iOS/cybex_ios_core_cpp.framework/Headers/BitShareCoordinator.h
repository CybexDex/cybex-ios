//
//  BitshareCoordinator.h
//  cybexMobile
//
//  Created by koofrank on 2018/4/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface BitShareCoordinator : NSObject
+ (NSString *)getUserKeys:(NSString *)username password:(NSString *)password;
+ (NSString *)getActiveUserKeys:(NSString *)publicKey;
+ (void)setDerivedOperationExtensions:(NSString *)master_public_key derived_private_key:(NSString *)derived_private_key
                   derived_public_key:(NSString *)derived_public_key nonce:(int)nonce signature:(NSString *)signature;

  /**
   需要先调用getuserkey
   **/

+ (NSString *)updateAccount:(int)block_num block_id:(NSString *)block_id
                 expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                  operation:(NSString *)operation;
+ (NSString *)getLimitOrder:(int)block_num block_id:(NSString *)block_id
                 expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                    user_id:(int)user_id order_expiration:(NSTimeInterval)order_expiration
                   asset_id:(int)asset_id amount:(int64_t)amount receive_asset_id:(int)receive_asset_id
             receive_amount:(int64_t)receive_amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;
+ (NSString *)getLimitOrderOperation:(int)user_id expiration:(NSTimeInterval)expiration asset_id:(int)asset_id amount:(int64_t)amount receive_asset_id:(int)receive_asset_id receive_amount:(int64_t)receive_amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;
+ (NSString *)cancelLimitOrder:(int)block_num block_id:(NSString *)block_id
                    expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                       user_id:(int)user_id order_id:(int)order_id
                        fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;
+ (NSString *)cancelLimitOrderOperation:(int)order_id user_id:(int)user_id fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;

// asset_id receive_asset_id 都为0 取消个人全部order
+ (NSString *)cancelAllLimitOrder:(int)block_num block_id:(NSString *)block_id
                    expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                       user_id:(int)user_id asset_id:(int)asset_id receive_asset_id:(int)receive_asset_id
                        fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;
+ (NSString *)cancelAllLimitOrderOperation:(int)asset_id receive_asset_id:(int)receive_asset_id user_id:(int)user_id fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;

  // memokey 需要线上取和生成的比较看是否有权限
+ (NSString *)getTransaction:(int)block_num block_id:(NSString *)block_id
                  expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                from_user_id:(int)from_user_id to_user_id:(int)to_user_id
                    asset_id:(int)asset_id receive_asset_id:(int)receive_asset_id
                      amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_keyb;

+ (NSString *)getTransactionWithVesting:(int)block_num block_id:(NSString *)block_id
                  expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                from_user_id:(int)from_user_id to_user_id:(int)to_user_id
                    asset_id:(int)asset_id receive_asset_id:(int)receive_asset_id
                                 amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount
                                   memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key vestingPeroid:(uint64_t)peroid toPubKey:(NSString *)toPubKey;

+ (NSString *)getTransactionId:(int)block_num block_id:(NSString *)block_id
                  expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                from_user_id:(int)from_user_id to_user_id:(int)to_user_id
                    asset_id:(int)asset_id receive_asset_id:(int)receive_asset_id
                      amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key;

+ (NSString *)getTransterOperation:(int)from_user_id to_user_id:(int)to_user_id asset_id:(int)asset_id amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key;

+ (NSString *)getTransterWithVestingOperation:(int)from_user_id to_user_id:(int)to_user_id asset_id:(int)asset_id amount:(int64_t)amount fee_id:(int)fee_id fee_amount:(int64_t)fee_amount memo:(NSString *)memo from_memo_key:(NSString *)from_memo_key to_memo_key:(NSString *)to_memo_key vestingPeroid:(uint64_t)peroid toPubKey:(NSString *)toPubKey;

+ (NSString *)exchangeParticipateJSON:(int)user_id exchange_id:(int)exchange_id
                             asset_id:(int)asset_id amount:(int64_t)amount
                               fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;

+ (NSString *)exchangeParticipate:(int)block_num block_id:(NSString *)block_id
                    expiration:(NSTimeInterval)expiration chain_id:(NSString *)chain_id
                       user_id:(int)user_id exchange_id:(int)exchange_id
                          asset_id:(int)asset_id amount:(int64_t)amount
                        fee_id:(int)fee_id fee_amount:(int64_t)fee_amount;

+ (void)resetDefaultPublicKey:(NSString *)str;//每次登录设置默认签名的公钥  默认为active-key
  
+ (void)cancelUserKey;
  
  
+ (NSString *)transactionIdFromSigned:(NSString *)jsonStr;
+ (NSString *)getRecodeLoginOperation:(NSString *)accountName asset:(NSString *)asset fundType:(NSString *)fundType size:(int)size offset:(int)offset expiration:(int)expiration;
  
+ (NSString *)getMemo:(NSString *)memo;
+ (NSString *)sign:(NSString *)str;
+ (NSString *)signMessage:(NSString *)username message:(NSString *)message;


/*
 unsigned_int fee_asset_id,
 amount_type fee_amount,
 unsigned_int deposit_to_account_id,
 unsigned_int claimed_id,
 string to_account_pub_key,
 unsigned_int claimed_asset_id,
 amount_type claimed_amount
 */
//锁定期资产
+ (NSString *)getClaimedSign:(int)block_num
                    block_id:(NSString *)block_id
                  expiration:(NSTimeInterval)expiration
                    chain_id:(NSString *)chain_id
                fee_asset_id:(int)fee_asset_id
                  fee_amount:(int64_t)fee_amount
       deposit_to_account_id:(int)deposit_to_account_id
                  claimed_id:(int)claimed_id
            claimed_asset_id:(int)claimed_asset_id
              claimed_amount:(int64_t)claimed_amount
          claimed_own:(NSString *)claimed_own;

+ (NSString *)getClaimedOperation:(int)fee_asset_id
                       fee_amount:(int64_t)fee_amount
            deposit_to_account_id:(int)deposit_to_account_id
                           claimed_id:(int)claimed_id
                           claimed_asset_id:(int)claimed_asset_id
                       claimed_amount:(int64_t)claimed_amount
                             claimed_own:(NSString *)claimed_own;

+ (NSString *)generatePrivateKey:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
