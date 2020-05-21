# Orchid - WebRTC P2P VPN Market (on Ethereum)
# Copyright (C) 2017-2019  The Orchid Authors

# Zero Clause BSD license {{{
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# }}}


pwd/gmp := $(pwd)/gmp

w_gmp += --enable-maintainer-mode

ifeq ($(target),win)
# XXX: -fdata-sections breaks libgmp's disassembly sed trick
w_gmp += gmp_cv_asm_rodata=$$'\t.section\t.rdata,"dr"'
endif

$(output)/%/$(pwd/gmp)/.libs/libgmp.a: $(output)/%/$(pwd/gmp)/Makefile
	$(MAKE) -C $(output)/$*/$(pwd/gmp)

linked += $(pwd/gmp)/.libs/libgmp.a

export NETTLE_STATIC := 1
