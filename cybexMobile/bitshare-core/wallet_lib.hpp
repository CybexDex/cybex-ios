#include <fc/crypto/elliptic.hpp>
#include <fc/io/varint.hpp>
//#include <fc/optional.hpp>
#include <string>
#include "graphene/chain/protocol/types.hpp"

using namespace std;
using namespace fc;

//#include "types.hpp"

//typedef fc::optional<fc::ecc::private_key> cybex_priv_key_type;
//extern cybex_priv_key_type active_priv_key, owner_priv_key, memo_priv_key;
typedef int64_t amount_type;
string get_user_key(string user_name, string password);
fc::ecc::private_key& get_private_key(string public_key);
void clear_user_key();
void set_default_public_key(string pub_key_base58_str);

string transfer(
                uint16_t ref_block_num,
                string ref_block_id_hex_str,
                uint32_t expiration, /* expiration time in utc seconds */
                string chain_id_str,
                
                unsigned_int from_id, /* instance id of from account */
                unsigned_int to_id, /* instance id of to account */
                amount_type amount, /* amount to be transfered */
                unsigned_int asset_id, /* instance id of asset to be transfered */
                amount_type fee_amount, /* amount of fee */
                unsigned_int fee_asset_id, /* instance id of asset to pay fee */
                string memo, /* memo data to be transfered, if no memo data, just use empty string */
                string from_memo_pub_key, /* public memo */
                string to_memo_pub_key
                );

string get_transfer_op_json(
                            unsigned_int from_id, /* instance id of from account */
                            unsigned_int to_id, /* instance id of to account */
                            amount_type amount, /* amount to be transfered */
                            unsigned_int asset_id, /* instance id of asset to be transfered */
                            amount_type fee_amount, /* amount of fee */
                            unsigned_int fee_asset_id, /* instance id of asset to pay fee */
                            string memo, /* memo data to be transfered, if no memo data, just use empty string */
                            string from_memo_pub_key, /* public memo */
                            string to_memo_pub_key
                            );

string limit_order_create(
                          uint16_t ref_block_num,
                          string ref_block_id_hex_str,
                          uint32_t expiration, /* expiration time in utc seconds */
                          string chain_id_str,
                          
                          unsigned_int seller_id, /* instance id of seller account */
                          uint32_t order_expiration,
                          unsigned_int sell_asset_id, /* instance id fo asset to be sold */
                          amount_type sell_amount, /* amount to be sold */
                          unsigned_int receive_asset_id, /* instance id of asset to receive */
                          amount_type min_to_receive, /* min asset to receive */
                          int fill_or_kill, /* 1 for true, 0 for false */
                          amount_type fee_amount, /* amount of fee */
                          unsigned_int fee_asset_id /* instance id of asset to pay fee*/
);

string get_limit_order_create_json(
                                   unsigned_int seller_id, /* instance id of seller account */
                                   uint32_t order_expiration,
                                   unsigned_int sell_asset_id, /* instance id fo asset to be sold */
                                   amount_type sell_amount, /* amount to be sold */
                                   unsigned_int receive_asset_id, /* instance id of asset to receive */
                                   amount_type min_to_receive, /* min asset to receive */
                                   int fill_or_kill, /* 1 for true, 0 for false */
                                   amount_type fee_amount, /* amount of fee */
                                   unsigned_int fee_asset_id /* instance id of asset to pay fee*/
);

string cancel_order(
                    uint16_t ref_block_num,
                    string ref_block_id_hex_str,
                    uint32_t expiration, /* expiration time in utc seconds */
                    string chain_id_str,
                    
                    unsigned_int order_id, /* instance id of order */
                    unsigned_int fee_paying_account_id, /* instance id of fee paying account */
                    amount_type fee_amount, /* amount of fee */
                    unsigned_int fee_asset_id /* instance id of asset to pay fee */
);

string get_cancel_order_json(
                             unsigned_int order_id, /* instance id of order */
                             unsigned_int fee_paying_account_id, /* instance id of fee paying account */
                             amount_type fee_amount, /* amount of fee */
                             unsigned_int fee_asset_id /* instance id of asset to pay fee */
);

string cybex_gateway_query(
                           string accountName,
                           string asset,
                           string fundType,
                           uint32_t size,
                           uint32_t offset,
                           uint32_t expiration
                           );

string decrypt_memo_data(
                         string memo_json_str
                         );
