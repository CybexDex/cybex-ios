//
//  TLVBox.m
//  ColdCornOC
//
//  Created by Victor Xu on 2018/7/3.
//  Copyright © 2018年 Smiacter Yin. All rights reserved.
//

#import "TLVBox.h"

@implementation TLVBox
int mTotalBytes=0;

-(instancetype)init{
    if (self = [super init]) {
    _tlvDic=[[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSMutableDictionary *)parse:(NSData *)tlvData{
    Byte *buffer=(Byte*)[tlvData bytes];
    int lenght=(int)[tlvData length];
    int parsed=0;
    while(parsed<lenght){
        NSData *type=[tlvData subdataWithRange:NSMakeRange(parsed, 1)];
        parsed += 1;
        int size = buffer[parsed] & 0xff;
        parsed += 1;
        if(size==0xff){
           NSData *d= [tlvData subdataWithRange:NSMakeRange(parsed, 2)];
            [d getBytes:&size length:sizeof(size)];
            parsed+=2;
        }
        [self putBytes:type andValue:[tlvData subdataWithRange:NSMakeRange(parsed, size)]];
        parsed += size;
    }
    return _tlvDic;
}

- (NSData *)serialize{
    NSMutableData *data=[[NSMutableData alloc] init];
    NSArray *allKeys=[_tlvDic allKeys];
    int offset=0;
    for(int i=0;i<allKeys.count;i++){
        NSData *key=[allKeys objectAtIndex:i];
        NSData *value=[_tlvDic objectForKey:key];
        [data appendData:key];
        offset+=1;
        int size=(int)value.length;
        if(size<0xff){
            NSData *sizeData = [NSData dataWithBytes:&size length: sizeof(size)];
            [data appendData:[sizeData subdataWithRange:NSMakeRange(0, 1)]];
            offset+=1;
        }else{
            int sizeFF=0xff;
            NSData *size1=[NSData dataWithBytes:&sizeFF length: sizeof(sizeFF)];
            NSData *size2=[NSData dataWithBytes:&size length: sizeof(size)];
            [data appendData:[size1 subdataWithRange:NSMakeRange(0, 1)]];
            [data appendData:[size2 subdataWithRange:NSMakeRange(0, 2)]];
            offset+=3;
        }
        [data appendData:value];
        offset+=value.length;
    }
    return data;
}

-(void)putBytes:(NSData*) type andValue:(NSData*)value{
    [_tlvDic setObject:value forKey:type];
    if (value.length < 0xff) {
        mTotalBytes += value.length + 2;
    } else {
        mTotalBytes += value.length + 4;
    }
}
@end
