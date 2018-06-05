#include <string>
#include <fc/container/flat.hpp>
#include <fc/io/json.hpp>
#include <fc/smart_ref_impl.hpp>
#include "graphene/chain/protocol/types.hpp"
#include "graphene/chain/protocol/transfer.hpp"
#include "transaction.hpp"
#include "wallet_lib.hpp"

using namespace std;
using namespace fc;
using namespace graphene::chain;

<<<<<<< HEAD
static void _init_transaction(
                              signed_transaction& tx,
                              uint16_t ref_block_num,
                              string ref_block_id_hex_str,
                              uint32_t tx_expiration
                              )
{
  block_id_type ref_block_id(ref_block_id_hex_str);
  tx.ref_block_num = ref_block_num;
  tx.ref_block_prefix = ref_block_id._hash[1];
  tx.expiration = fc::time_point_sec(tx_expiration);
}

static void _set_transfer_operation(
                                    transfer_operation& o,
                                    unsigned_int from_id, /* instance id of from account */
                                    unsigned_int to_id, /* instance id of to account */
                                    int amount, /* amount to be transfered */
                                    unsigned_int asset_id, /* instance id of asset to be transfered */
                                    int fee_amount, /* amount of fee */
                                    unsigned_int fee_asset_id, /* instance id of asset to pay fee */
                                    string memo, /* memo data to be transfered, if no memo data, just use empty string */
                                    string from_memo_pub_key, /* public memo, in base58 str */
                                    string to_memo_pub_key /* to memo, in base58 str*/
)
{
  o.fee.amount = fee_amount;
  o.fee.asset_id.instance = fee_asset_id;
  
  o.from.instance = from_id;
  o.to.instance = to_id;
  
  o.amount.amount = amount;
  o.amount.asset_id = asset_id;
  
  if(memo.size())
  {
    o.memo = memo_data();
    //o.memo->from = fc::ecc::public_key::from_base58(from_memo_pub_key);
    //o.memo->to = fc::ecc::public_key::from_base58(to_memo_pub_key);
    fc::ecc::private_key memo_priv_key = get_private_key(from_memo_pub_key);
    o.memo->from = public_key_type(from_memo_pub_key);
    o.memo->to = public_key_type(to_memo_pub_key);
    o.memo->set_message(memo_priv_key, o.memo->to, memo);
  }
}

string transfer(
                uint16_t ref_block_num,
                string ref_block_id_hex_str,
                uint32_t expiration, /* expiration time in utc seconds */
                string chain_id_str, /* chain id in base58 */
                unsigned_int from_id, /* instance id of from account */
                unsigned_int to_id, /* instance id of to account */
                int amount, /* amount to be transfered */
                unsigned_int asset_id, /* instance id of asset to be transfered */
                int fee_amount, /* amount of fee */
                unsigned_int fee_asset_id, /* instance id of asset to pay fee */
                string memo, /* memo data to be transfered, if no memo data, just use empty string */
                string from_memo_pub_key, /* public memo, in base58 str */
                string to_memo_pub_key /* to memo, in base58 str*/
)
{ try{
  fc::ecc::private_key active_priv_key = get_private_key();
  
  transfer_operation o;
  
  _set_transfer_operation(o, from_id, to_id, amount, asset_id, fee_amount, fee_asset_id, memo, from_memo_pub_key, to_memo_pub_key);
  
  signed_transaction signed_tx;
  _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);
  
  signed_tx.operations.push_back(o);
  
  chain_id_type chain_id(chain_id_str);
  signed_tx.sign(active_priv_key, chain_id);
  variant tx(signed_tx);
  return fc::json::to_string(tx);
} catch(...) {return "";}}

string get_transfer_op_json(
                            unsigned_int from_id, /* instance id of from account */
                            unsigned_int to_id, /* instance id of to account */
                            int amount, /* amount to be transfered */
                            unsigned_int asset_id, /* instance id of asset to be transfered */
                            int fee_amount, /* amount of fee */
                            unsigned_int fee_asset_id, /* instance id of asset to pay fee */
                            string memo, /* memo data to be transfered, if no memo data, just use empty string */
                            string from_memo_pub_key, /* public memo */
                            string to_memo_pub_key
                            )
{ try {
  transfer_operation o;
  _set_transfer_operation(o, from_id, to_id, amount, asset_id, fee_amount, fee_asset_id, memo, from_memo_pub_key, to_memo_pub_key);
  variant op_json(o);
  return fc::json::to_string(op_json);
} catch(...) {return "";}}

void _set_limit_order_create_operation(
                                       limit_order_create_operation &o,
                                       unsigned_int seller_id, /* instance id of seller account */
                                       uint32_t order_expiration,
                                       unsigned_int sell_asset_id, /* instance id fo asset to be sold */
                                       int sell_amount, /* amount to be sold */
                                       unsigned_int receive_asset_id, /* instance id of asset to receive */
                                       int min_to_receive, /* min asset to receive */
                                       int fill_or_kill, /* 1 for true, 0 for false */
                                       int fee_amount, /* amount of fee */
                                       unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{
  o.seller.instance = seller_id;
  o.expiration = fc::time_point_sec(order_expiration);
  o.amount_to_sell.asset_id = sell_asset_id;
  o.amount_to_sell.amount = sell_amount;
  o.min_to_receive.asset_id = receive_asset_id;
  o.min_to_receive.amount = min_to_receive;
  o.fill_or_kill = (fill_or_kill == 0 ? false:true);
  o.fee.amount = fee_amount;
  o.fee.asset_id = fee_asset_id;
}

string limit_order_create(
                          uint16_t ref_block_num,
                          string ref_block_id_hex_str,
                          uint32_t expiration, /* expiration time in utc seconds */
                          string chain_id_str,
                          unsigned_int seller_id, /* instance id of seller account */
                          uint32_t order_expiration,
                          unsigned_int sell_asset_id, /* instance id fo asset to be sold */
                          int sell_amount, /* amount to be sold */
                          unsigned_int receive_asset_id, /* instance id of asset to receive */
                          int min_to_receive, /* min asset to receive */
                          int fill_or_kill, /* 1 for true, 0 for false */
                          int fee_amount, /* amount of fee */
                          unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{ try {
  fc::ecc::private_key active_priv_key = get_private_key();
  
  limit_order_create_operation o;
  _set_limit_order_create_operation(o, seller_id, order_expiration,
                                    sell_asset_id, sell_amount, receive_asset_id, min_to_receive, fill_or_kill, fee_amount, fee_asset_id);
  
  signed_transaction signed_tx;
  _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);
  
  signed_tx.operations.push_back(o);
  
  chain_id_type chain_id(chain_id_str);
  signed_tx.sign(active_priv_key, chain_id);
  variant tx(signed_tx);
  return fc::json::to_string(tx);
} catch(...) {return "";}}

string get_limit_order_create_json(
                                   unsigned_int seller_id, /* instance id of seller account */
                                   uint32_t order_expiration,
                                   unsigned_int sell_asset_id, /* instance id fo asset to be sold */
                                   int sell_amount, /* amount to be sold */
                                   unsigned_int receive_asset_id, /* instance id of asset to receive */
                                   int min_to_receive, /* min asset to receive */
                                   int fill_or_kill, /* 1 for true, 0 for false */
                                   int fee_amount, /* amount of fee */
                                   unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{ try {
  limit_order_create_operation o;
  _set_limit_order_create_operation(o, seller_id, order_expiration,
                                    sell_asset_id, sell_amount, receive_asset_id, min_to_receive, fill_or_kill, fee_amount, fee_asset_id);
  variant op_json(o);
  return fc::json::to_string(op_json);
} catch(...) {return "";}}

static void _set_cancel_order_operation(
                                        limit_order_cancel_operation &o,
                                        unsigned_int order_id, /* instance id of order */
                                        unsigned_int fee_paying_account_id, /* instance id of fee paying account */
                                        int fee_amount, /* amount of fee */
                                        unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{
  o.order = order_id;
  o.fee_paying_account = fee_paying_account_id;
  o.fee.amount = fee_amount;
  o.fee.asset_id = fee_asset_id;
}

string cancel_order(
                    uint16_t ref_block_num,
                    string ref_block_id_hex_str,
                    uint32_t expiration, /* expiration time in utc seconds */
                    string chain_id_str,
                    
                    unsigned_int order_id, /* instance id of order */
                    unsigned_int fee_paying_account_id, /* instance id of fee paying account */
                    int fee_amount, /* amount of fee */
                    unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{ try {
  fc::ecc::private_key active_priv_key = get_private_key();
  
  limit_order_cancel_operation o;
  _set_cancel_order_operation(o,
                              order_id, fee_paying_account_id, fee_amount, fee_asset_id);
  
  signed_transaction signed_tx;
  _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);
  
  signed_tx.operations.push_back(o);
  
  chain_id_type chain_id(chain_id_str);
  signed_tx.sign(active_priv_key, chain_id);
  variant tx(signed_tx);
  return fc::json::to_string(tx);
} catch(...){return "";}}

string get_cancel_order_json(
                             unsigned_int order_id, /* instance id of order */
                             unsigned_int fee_paying_account_id, /* instance id of fee paying account */
                             int fee_amount, /* amount of fee */
                             unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{ try {
  limit_order_cancel_operation o;
  _set_cancel_order_operation(o,
                              order_id, fee_paying_account_id, fee_amount, fee_asset_id);
  variant op_json(o);
  return fc::json::to_string(op_json);
=======
extern cybex_priv_key_type active_priv_key;

static void _init_transaction(
    signed_transaction& tx,
    uint16_t ref_block_num,
    string ref_block_id_hex_str,
    uint32_t tx_expiration
)
{
    block_id_type ref_block_id(ref_block_id_hex_str);
    tx.ref_block_num = ref_block_num;
    tx.ref_block_prefix = ref_block_id._hash[1];
    tx.expiration = fc::time_point_sec(tx_expiration);
}

static void _set_transfer_operation(
    transfer_operation& o,
    unsigned_int from_id, /* instance id of from account */
    unsigned_int to_id, /* instance id of to account */
    int amount, /* amount to be transfered */
    unsigned_int asset_id, /* instance id of asset to be transfered */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id, /* instance id of asset to pay fee */
    string memo, /* memo data to be transfered, if no memo data, just use empty string */
    string from_memo_pub_key, /* public memo, in base58 str */
    string to_memo_pub_key /* to memo, in base58 str*/
)
{
    o.fee.amount = fee_amount;
    o.fee.asset_id.instance = fee_asset_id;

    o.from.instance = from_id;
    o.to.instance = to_id;

    o.amount.amount = amount;
    o.amount.asset_id = asset_id;

    if(memo.size())
    {
        o.memo = memo_data();
        //o.memo->from = fc::ecc::public_key::from_base58(from_memo_pub_key);
        //o.memo->to = fc::ecc::public_key::from_base58(to_memo_pub_key);
        o.memo->from = public_key_type(from_memo_pub_key);
        o.memo->to = public_key_type(to_memo_pub_key);
        o.memo->set_message(*memo_priv_key, o.memo->to, memo);
    }
}

string transfer(
    uint16_t ref_block_num,
    string ref_block_id_hex_str,
    uint32_t expiration, /* expiration time in utc seconds */
    string chain_id_str, /* chain id in base58 */
    unsigned_int from_id, /* instance id of from account */
    unsigned_int to_id, /* instance id of to account */
    int amount, /* amount to be transfered */
    unsigned_int asset_id, /* instance id of asset to be transfered */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id, /* instance id of asset to pay fee */
    string memo, /* memo data to be transfered, if no memo data, just use empty string */
    string from_memo_pub_key, /* public memo, in base58 str */
    string to_memo_pub_key /* to memo, in base58 str*/
)
{ try{
    if(!active_priv_key.valid())
    {
        return "";
    }

    transfer_operation o;

    _set_transfer_operation(o, from_id, to_id, amount, asset_id, fee_amount, fee_asset_id, memo, from_memo_pub_key, to_memo_pub_key);

    signed_transaction signed_tx;
    _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);

    signed_tx.operations.push_back(o);

    chain_id_type chain_id(chain_id_str);
    signed_tx.sign(*active_priv_key, chain_id);
    variant tx(signed_tx);
    return fc::json::to_string(tx);
} catch(...) {return "";}}

string get_transfer_op_json(
    unsigned_int from_id, /* instance id of from account */
    unsigned_int to_id, /* instance id of to account */
    int amount, /* amount to be transfered */
    unsigned_int asset_id, /* instance id of asset to be transfered */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id, /* instance id of asset to pay fee */
    string memo, /* memo data to be transfered, if no memo data, just use empty string */
    string from_memo_pub_key, /* public memo */
    string to_memo_pub_key
)
{ try {
    transfer_operation o;
    _set_transfer_operation(o, from_id, to_id, amount, asset_id, fee_amount, fee_asset_id, memo, from_memo_pub_key, to_memo_pub_key);
    variant op_json(o);
    return fc::json::to_string(op_json);
} catch(...) {return "";}}

void _set_limit_order_create_operation(
    limit_order_create_operation &o,
    unsigned_int seller_id, /* instance id of seller account */
    uint32_t order_expiration,
    unsigned_int sell_asset_id, /* instance id fo asset to be sold */
    int sell_amount, /* amount to be sold */
    unsigned_int receive_asset_id, /* instance id of asset to receive */ 
    int min_to_receive, /* min asset to receive */
    int fill_or_kill, /* 1 for true, 0 for false */ 
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{
    o.seller.instance = seller_id;
    o.expiration = fc::time_point_sec(order_expiration);
    o.amount_to_sell.asset_id = sell_asset_id;
    o.amount_to_sell.amount = sell_amount;
    o.min_to_receive.asset_id = receive_asset_id;
    o.min_to_receive.amount = min_to_receive;
    o.fill_or_kill = (fill_or_kill == 0 ? false:true);
    o.fee.amount = fee_amount;
    o.fee.asset_id = fee_asset_id;
}

string limit_order_create(
    uint16_t ref_block_num,
    string ref_block_id_hex_str,
    uint32_t expiration, /* expiration time in utc seconds */
    string chain_id_str,
    unsigned_int seller_id, /* instance id of seller account */
    uint32_t order_expiration,
    unsigned_int sell_asset_id, /* instance id fo asset to be sold */
    int sell_amount, /* amount to be sold */
    unsigned_int receive_asset_id, /* instance id of asset to receive */ 
    int min_to_receive, /* min asset to receive */
    int fill_or_kill, /* 1 for true, 0 for false */ 
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{ try {
    if(!active_priv_key.valid())
    {
        return "";
    }

    limit_order_create_operation o;
    _set_limit_order_create_operation(o, seller_id, order_expiration,
sell_asset_id, sell_amount, receive_asset_id, min_to_receive, fill_or_kill, fee_amount, fee_asset_id);
    
    signed_transaction signed_tx;
    _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);

    signed_tx.operations.push_back(o);

    chain_id_type chain_id(chain_id_str);
    signed_tx.sign(*active_priv_key, chain_id);
    variant tx(signed_tx);
    return fc::json::to_string(tx);
} catch(...) {return "";}}

string get_limit_order_create_json(
    unsigned_int seller_id, /* instance id of seller account */
    uint32_t order_expiration,
    unsigned_int sell_asset_id, /* instance id fo asset to be sold */
    int sell_amount, /* amount to be sold */
    unsigned_int receive_asset_id, /* instance id of asset to receive */ 
    int min_to_receive, /* min asset to receive */
    int fill_or_kill, /* 1 for true, 0 for false */ 
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee*/
)
{ try {
    limit_order_create_operation o;
    _set_limit_order_create_operation(o, seller_id, order_expiration,
sell_asset_id, sell_amount, receive_asset_id, min_to_receive, fill_or_kill, fee_amount, fee_asset_id);
    variant op_json(o);
    return fc::json::to_string(op_json);
} catch(...) {return "";}}

static void _set_cancel_order_operation(
    limit_order_cancel_operation &o,
    unsigned_int order_id, /* instance id of order */
    unsigned_int fee_paying_account_id, /* instance id of fee paying account */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{
    o.order = order_id;
    o.fee_paying_account = fee_paying_account_id;
    o.fee.amount = fee_amount;
    o.fee.asset_id = fee_asset_id;
}

string cancel_order(
    uint16_t ref_block_num,
    string ref_block_id_hex_str,
    uint32_t expiration, /* expiration time in utc seconds */
    string chain_id_str,
    
    unsigned_int order_id, /* instance id of order */
    unsigned_int fee_paying_account_id, /* instance id of fee paying account */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{ try {
    if(!active_priv_key.valid())
    {
        return "";
    }

    limit_order_cancel_operation o;
    _set_cancel_order_operation(o,
        order_id, fee_paying_account_id, fee_amount, fee_asset_id);

    signed_transaction signed_tx;
    _init_transaction(signed_tx, ref_block_num, ref_block_id_hex_str, expiration);

    signed_tx.operations.push_back(o);

    chain_id_type chain_id(chain_id_str);
    signed_tx.sign(*active_priv_key, chain_id);
    variant tx(signed_tx);
    return fc::json::to_string(tx);
} catch(...){return "";}}

string get_cancel_order_json(
    unsigned_int order_id, /* instance id of order */
    unsigned_int fee_paying_account_id, /* instance id of fee paying account */
    int fee_amount, /* amount of fee */
    unsigned_int fee_asset_id /* instance id of asset to pay fee */
)
{ try {
    limit_order_cancel_operation o;
    _set_cancel_order_operation(o,
        order_id, fee_paying_account_id, fee_amount, fee_asset_id);
    variant op_json(o);
    return fc::json::to_string(op_json);
>>>>>>> 178af5bada3bb1d2ba2fe2e86f2ea7dc5877b7d4
} catch(...){return "";}}
