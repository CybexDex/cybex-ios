//
//  cybex_gateway_query.cpp
//  cybexMobile
//
//  Created by koofrank on 2018/7/17.
//  Copyright © 2018年 Cybex. All rights reserved.
//

#include <string>

#ifndef CYBEX_GATEWAY_QUERY
#define CYBEX_GATEWAY_QUERY

#include <fc/reflect/reflect.hpp>
#include "graphene/chain/protocol/types.hpp"

using namespace fc;

struct cybex_gateway_query_operation
{
  string accountName;
  optional<string> asset;
  optional<string> fundType;
  optional<uint32_t> size;
  optional<uint32_t> offset;
  time_point_sec expiration;
};

FC_REFLECT(cybex_gateway_query_operation, (accountName)(asset)(fundType)(size)(offset)(expiration))

#endif
