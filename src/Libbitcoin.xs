#define PERL_NO_GET_CONTEXT
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#ifdef __cplusplus
}
#endif

#include <bitcoin/bitcoin.hpp>


MODULE = Libbitcoin  PACKAGE = Libbitcoin

MODULE = Libbitcoin  PACKAGE = Libbitcoin::Constants

BOOT:
{
    using namespace libbitcoin;
    HV* stash = gv_stashpv("Libbitcoin::Constants", GV_ADDWARN);

    // TODO: unspecified_ip_address, unspecified_network_address
    newCONSTSUB(stash, "BC_USER_AGENT",        newSVpv(BC_USER_AGENT, 0));
    newCONSTSUB(stash, "COMMAND_SIZE",         newSViv(command_size));
    newCONSTSUB(stash, "PROTOCOL_VERSION",     newSViv(protocol_version));
    newCONSTSUB(stash, "PEER_MINIMUM_VERSION", newSViv(peer_minimum_version));
    newCONSTSUB(stash, "REWARD_INTERVAL",      newSViv(reward_interval));
    newCONSTSUB(stash, "COINBASE_MATURITY",    newSViv(coinbase_maturity));
    newCONSTSUB(stash, "INITIAL_BLOCK_REWARD", newSViv(initial_block_reward));
    newCONSTSUB(stash, "MAX_WORK_BITS",        newSViv(max_work_bits));
    newCONSTSUB(stash, "MAX_INPUT_SEQUENCE",   newSViv(max_input_sequence));
    newCONSTSUB(stash, "LOCKTIME_THRESHOLD",   newSViv(locktime_threshold));
    newCONSTSUB(stash, "NODE_NETWORK",         newSViv(node_network));
    newCONSTSUB(stash, "NODE_UTXO",            newSViv(node_utxo));
    newCONSTSUB(stash, "BLOOM_FILTERS",        newSViv(bloom_filters));
    newCONSTSUB(stash, "NO_TIMESTAMP",         newSViv(no_timestamp));
    newCONSTSUB(stash, "UNSPECIFIED_IP_PORT",  newSViv(unspecified_ip_port));
    newCONSTSUB(stash, "LIBBITCOIN_VERSION",   newSVpv(LIBBITCOIN_VERSION, 0));
}

