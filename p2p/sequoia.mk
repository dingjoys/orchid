# Orchid - WebRTC P2P VPN Market (on Ethereum)
# Copyright (C) 2017-2019  The Orchid Authors

# Zero Clause BSD license {{{
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# }}}


linked += $(pwd)/sequoia-openpgp-ffi/$(pre)rust.$(lib)
cflags += -I$(pwd)/sequoia-openpgp-ffi/opengpg-ffi/include
$(call depend,$(pwd)/sequoia-openpgp-ffi/$(pre)rust.$(lib),$(patsubst %,@/openssl/include/openssl/%.h,opensslconf opensslv) @/$(pwd)/gmp/.libs/libgmp.a @/$(pwd)/nettle/libnettle.a @/$(pwd)/nettle/libhogweed.a)
