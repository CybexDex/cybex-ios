//
//  TLVBox.h
//  ColdCornOC
//
//  Created by Victor Xu on 2018/7/3.
//  Copyright © 2018年 Smiacter Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLVBox : NSObject


#define  Device_Certificate @"30"
#define  Account @"32"
#define  BlockChain_PublicKey @"55"
#define  Master_PublicKey @"57"
#define  SlavePrivateKey @"58"
#define  KeyDeriveNonce  @"74"
#define  KeyDeriveDigest @"75"
#define  KeyDeriveSignature @"76"

@property(nonatomic,strong)NSMutableDictionary *tlvDic;

-(NSDictionary*)parse:(NSData*) tlvData;
-(NSData*)serialize;
-(void)putBytes:(NSData*) type andValue:(NSData*)value;
@end
