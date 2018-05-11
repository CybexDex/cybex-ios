//
//  BitShareCoordinator.m
//  cybexMobile
//
//  Created by koofrank on 2018/4/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BitShareCoordinator.h"

#include <iostream>
#include "test_boost_json.hpp"

using namespace std;

@implementation BitShareCoordinator

+ (void)callMethod:(NSString *)str {
  string parse_result = get_dev_key([str UTF8String]);
 
  NSString *result = @(parse_result.c_str());
  
}

@end
