//
//  Utils.m
//  Core NFC Example
//
//  Created by Victor Xu on 2019/2/21.
//  Copyright © 2019 Zhi-Wei Cai. All rights reserved.
//

#import "Utils.h"
#import "TLVBox.h"

@implementation Utils
/// 16进制字符串转NSData
+ (NSData *)hexStringToHexData:(NSString *)hexStr
{
    NSUInteger len = [hexStr length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [hexStr length] / 2; i++) {
        byte_chars[0] = [hexStr characterAtIndex:i*2];
        byte_chars[1] = [hexStr characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

/// 16进制Data转化为字符串
+ (NSString *)hexDataToHexStr:(NSData *)hexData
{
    if (!hexData || [hexData length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[hexData length]];
    
    [hexData enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

+ (NSString *)dataToBase64Str: (NSData *)data {
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (Card *)parseNDEFMessage:(NSArray<NFCNDEFMessage *> *)messages
{
    for (NFCNDEFMessage *message in messages) {
        NSArray<NFCNDEFPayload *>* mRecords = message.records;
        if(mRecords.count==3){
            NFCNDEFPayload* payload = [mRecords objectAtIndex:2];
            return [Utils parseData:payload.payload];
        }
    }
    return nil;
}

+ (Card *)parseData:(NSData *)data
{
    Card* card=[[Card alloc] init];
    TLVBox* tlvBox = [[TLVBox alloc] init];
    NSDictionary *tlvIdc = [tlvBox parse:data];
    NSLog(@"%@",tlvIdc.allKeys);
    NSString* blockChainPublicKey = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:BlockChain_PublicKey]]];
    NSString* masterPublicKey = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:Master_PublicKey]]];
    NSString* derivePrivatekey = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:SlavePrivateKey]]];
    NSString* keyDeriveNonce = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:KeyDeriveNonce]]];
    NSString* keyDeriveDigest = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:KeyDeriveDigest]]];
    NSString* keyDeriveSignature = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:KeyDeriveSignature]]];
    NSString* device_Certificate = [Utils hexDataToHexStr:[tlvIdc objectForKey:[Utils hexStringToHexData:Device_Certificate]]];
    NSString* account = [[NSString alloc] initWithData:[tlvIdc objectForKey:[Utils hexStringToHexData:Account]] encoding:NSUTF8StringEncoding];
    
    card.blockchainPublicKey=blockChainPublicKey;
    card.masterPublicKey=masterPublicKey;
    card.derivePrivatekey=derivePrivatekey;
    card.deriveNonce=keyDeriveNonce;
    card.deriveDigest=keyDeriveDigest;
    card.deriveSignature=keyDeriveSignature;
    card.certificate=device_Certificate;
    card.account=account;
    
    return card;
}
@end
