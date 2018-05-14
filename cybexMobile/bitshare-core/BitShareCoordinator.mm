//
//  BitShareCoordinator.m
//  cybexMobile
//
//  Created by koofrank on 2018/4/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BitShareCoordinator.h"

#include "fc_bridge.hpp"

@implementation BitShareCoordinator

+ (NSString *)getUserKeys:(NSString *)username password:(NSString *)password {
  string keys = get_user_key([username UTF8String], [password UTF8String]);
 
  NSString *result = @(keys.c_str());
  
  return result;
}

@end
