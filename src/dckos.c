#include <kos.h>
#include <mruby.h>
#include <mruby/data.h>
#include <mruby/string.h>
#include <mruby/error.h>
#include <stdio.h>
#include <inttypes.h>

#define PACK_PIXEL(r, g, b) ( ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)  )

void print_exception(mrb_state* mrb) {
}

void define_module_functions(mrb_state* mrb, struct RClass* module) {
}
