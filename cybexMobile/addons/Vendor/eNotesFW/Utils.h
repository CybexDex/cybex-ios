//
//  Utils.h
//  Core NFC Example
//
//  Created by Victor Xu on 2019/2/21.
//  Copyright © 2019 Zhi-Wei Cai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
@import CoreNFC;

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject
+ (NSData *)hexStringToHexData:(NSString *)hexStr;
+ (NSString *)hexDataToHexStr:(NSData *)hexData;
+ (NSString *)dataToBase64Str: (NSData *)data;
+ (Card *)parseNDEFMessage:(NSArray<NFCNDEFMessage *> *)messages;
+ (Card *)parseData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
