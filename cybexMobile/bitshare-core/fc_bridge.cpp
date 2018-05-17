#include <string.h>
#include <iostream>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

using namespace std;
using namespace boost::property_tree;

#include <string>
#include <iostream>
#include <string.h>

#include "fc/crypto/elliptic.hpp"
#include "fc/crypto/ripemd160.hpp"
#include "fc/crypto/base58.hpp"
#include "fc/crypto/sha512.hpp"
#include "fc/io/json.hpp"
#include "fc/reflect/reflect.hpp"
#include "fc/io/raw.hpp"
#include "fc/variant_object.hpp"

using namespace std;

struct binary_key
{
  binary_key(){}
  uint32_t check = 0;
  fc::ecc::public_key_data data;
};

FC_REFLECT( binary_key, (data)(check) )

std::string key_to_wif(const fc::sha256& secret )
{
  const size_t size_of_data_to_hash = sizeof(secret) + 1;
  const size_t size_of_hash_bytes = 4;
  char data[size_of_data_to_hash + size_of_hash_bytes];
  data[0] = (char)0x80;
  memcpy(&data[1], (char*)&secret, sizeof(secret));
  fc::sha256 digest = fc::sha256::hash(data, size_of_data_to_hash);
  digest = fc::sha256::hash(digest);
  memcpy(data + size_of_data_to_hash, (char*)&digest, size_of_hash_bytes);
  return fc::to_base58(data, sizeof(data));
}

struct pts_address
{
  pts_address(); ///< constructs empty / null address
  pts_address( const std::string& base58str );   ///< converts to binary, validates checksum
  pts_address( const fc::ecc::public_key& pub, bool compressed = true, uint8_t version=56 ); ///< converts to binary
  
  uint8_t version()const { return addr.at(0); }
  bool is_valid()const;
  
  operator std::string()const; ///< converts to base58 + checksum
  
  fc::array<char,25> addr; ///< binary representation of address
};

pts_address::pts_address()
{
  memset( addr.data, 0, sizeof(addr.data) );
}

pts_address::pts_address( const std::string& base58str )
{
  std::vector<char> v = fc::from_base58( fc::string(base58str) );
  if( v.size() )
  memcpy( addr.data, v.data(), std::min<size_t>( v.size(), sizeof(addr) ) );
}

pts_address::pts_address( const fc::ecc::public_key& pub, bool compressed, uint8_t version )
{
  fc::sha256 sha2;
  if( compressed )
  {
    auto dat = pub.serialize();
    sha2     = fc::sha256::hash(dat.data, sizeof(dat) );
  }
  else
  {
    auto dat = pub.serialize_ecc_point();
    sha2     = fc::sha256::hash(dat.data, sizeof(dat) );
  }
  auto rep      = fc::ripemd160::hash((char*)&sha2,sizeof(sha2));
  addr.data[0]  = version;
  memcpy( addr.data+1, (char*)&rep, sizeof(rep) );
  auto check    = fc::sha256::hash( addr.data, sizeof(rep)+1 );
  check = fc::sha256::hash(check);
  memcpy( addr.data+1+sizeof(rep), (char*)&check, 4 );
}

/**
 *  Checks the address to verify it has a
 *  valid checksum
 */
bool pts_address::is_valid()const
{
  auto check    = fc::sha256::hash( addr.data, sizeof(fc::ripemd160)+1 );
  check = fc::sha256::hash(check);
  return memcmp( addr.data+1+sizeof(fc::ripemd160), (char*)&check, 4 ) == 0;
}

pts_address::operator std::string()const
{
  fc::ripemd160 addr = fc::ripemd160::hash( (char*)this, sizeof(*this) );
  fc::array<char,24> bin_addr;
  memcpy( (char*)&bin_addr, (char*)&addr, sizeof( addr ) );
  auto checksum = fc::ripemd160::hash( (char*)&addr, sizeof( addr ) );
  memcpy( ((char*)&bin_addr)+20, (char*)&checksum._hash[0], 4 );
  return "CYB" + fc::to_base58( bin_addr.data, sizeof( bin_addr ) );
}

fc::mutable_variant_object get_dev_key(string secret)
{
  fc::ecc::private_key priv_key = fc::ecc::private_key::regenerate(fc::sha256::hash(string(secret)));
  string private_key = key_to_wif( priv_key );
  fc::ecc::public_key pub_key = priv_key.get_public_key();
  struct binary_key bkey;
  bkey.data = pub_key.serialize();
  bkey.check = fc::ripemd160::hash( bkey.data.data, bkey.data.size() )._hash[0];
  
  auto data = fc::raw::pack( bkey );
  string public_key = "CYB" + fc::to_base58( data.data(), data.size() );
  
  auto dat = pub_key.serialize();
  fc::ripemd160 addr = fc::ripemd160::hash( fc::sha512::hash( dat.data, sizeof( dat ) ) );
  fc::array<char,24> bin_addr;
  
  memcpy( (char*)&bin_addr, (char*)&addr, sizeof( addr ) );
  auto checksum = fc::ripemd160::hash( (char*)&addr, sizeof( addr ) );
  memcpy( ((char*)&bin_addr)+20, (char*)&checksum._hash[0], 4 );
  string address = "CYB" + fc::to_base58( bin_addr.data, sizeof( bin_addr ) );
  
  struct pts_address compress_pts_addr(pub_key, true, 56);
  struct pts_address uncompress_pts_addr(pub_key, false, 56);
  
  fc::mutable_variant_object mvo;
  mvo( "private_key", private_key)
  ( "public_key", public_key)
  ( "address", address)
  ( "compressed", string(compress_pts_addr))
  ( "uncompressed", string(uncompress_pts_addr))
  ;
  return mvo;
  //return fc::json::to_string(mvo);
}

string get_user_key(string user_name, string password)
{
  fc::mutable_variant_object mvo;
  mvo("active-key", get_dev_key(user_name + "active" + password))
  ("owner-key", get_dev_key(user_name + "owner" + password))
  ("memo-key", get_dev_key(user_name + "memo" + password))
  ;
  return fc::json::to_string(mvo);
}
