#include <iostream>

using namespace std;

#include <string>
#include <iostream>
#include <string.h>

#include <fc/crypto/elliptic.hpp>
#include <fc/crypto/ripemd160.hpp>
#include <fc/io/json.hpp>
#include <fc/crypto/base58.hpp>
#include <fc/crypto/sha512.hpp>
#include <fc/reflect/reflect.hpp>
#include <fc/io/raw.hpp>
#include <fc/variant_object.hpp>

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

string get_dev_key(string secret)
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
  
  fc::mutable_variant_object mvo;
  mvo( "private_key", private_key)
  ( "public_key", public_key)
  ( "address", address)
  ;
  return fc::json::to_string(mvo);
}

