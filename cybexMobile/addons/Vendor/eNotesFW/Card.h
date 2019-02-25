//
//  Card.h
//  Core NFC Example
//
//  Created by Victor Xu on 2019/2/21.
//  Copyright © 2019 Zhi-Wei Cai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Card : NSObject
//这个key就是acitvePublickKey
@property NSString *blockchainPublicKey;
@property NSString *masterPublicKey;
@property NSString *derivePrivatekey;
@property NSString *deriveNonce;
@property NSString *deriveDigest;
@property NSString *deriveSignature;
@property NSString *certificate;
@property NSString *account;
@end

NS_ASSUME_NONNULL_END
