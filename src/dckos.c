#include <kos.h>
#include <mruby.h>
#include <mruby/data.h>
#include <mruby/string.h>
#include <mruby/error.h>
#include <stdio.h>
#include <inttypes.h>

#define PACK_PIXEL(r, g, b) ( ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)  )

// Be careful with this function. It'll attempt to read the entire file.
static mrb_value read_whole_txt_file(mrb_state* mrb, mrb_value self) {
  char buffer[2048];
  int length;
  file_t f;
  mrb_value m_path;
  char* path;

  char* result = NULL;
  result = mrb_malloc(mrb, sizeof(char));
  *result = '\0';

  mrb_get_args(mrb, "S", &m_path);
  path = mrb_str_to_cstr(mrb, m_path); // no need to free this
  f = fs_open(path, O_RDONLY);

  if(f < 0) {
    printf("Failed to open %s.\n", path);
    return mrb_nil_value();
  }

  while((length = fs_read(f, buffer, 2048))) {
    printf("read %i chars into buf.\n", length);
    result = realloc(result, strlen(result) + length);
    strncat(result, buffer, length);
  }

  fs_close(f);

  return mrb_str_new_cstr(mrb, result);
  // TODO: freeing?
}

static mrb_value get_button_state(mrb_state* mrb, mrb_value self) {
  maple_device_t *cont1;
  cont_state_t *state;
  if((cont1 = maple_enum_type(0, MAPLE_FUNC_CONTROLLER))){
    state = (cont_state_t *)maple_dev_status(cont1);
    return mrb_fixnum_value(state->buttons);
  }
  return mrb_nil_value();
}

static mrb_value check_btn(mrb_state* mrb, mrb_value self, uint16 target) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & target);
}

static mrb_value btn_start(mrb_state* mrb, mrb_value self) {
  return check_btn(mrb, self, CONT_START);
};

static mrb_value draw_str(mrb_state* mrb, mrb_value self) {
  char* unwrapped_content;
  mrb_value str_content;

  mrb_get_args(mrb, "S", &str_content);
  unwrapped_content = mrb_str_to_cstr(mrb, str_content); // no need to free this

  bfont_draw_str(vram_s, 640, 0, unwrapped_content);

  return mrb_nil_value();
}

void print_exception(mrb_state* mrb) {
  if(mrb->exc) {
    mrb_value backtrace = mrb_get_backtrace(mrb);
    puts(mrb_str_to_cstr(mrb, mrb_inspect(mrb, backtrace)));

    mrb_value obj = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    fwrite(RSTRING_PTR(obj), RSTRING_LEN(obj), 1, stdout);
    putc('\n', stdout);
  }
}

void define_module_functions(mrb_state* mrb, struct RClass* module) {
  mrb_define_module_function(mrb, module, "read_whole_txt_file", read_whole_txt_file, MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, module, "draw_str", draw_str, MRB_ARGS_REQ(1));
  mrb_define_module_function(mrb, module, "get_button_state", get_button_state, MRB_ARGS_NONE());
  mrb_define_module_function(mrb, module, "btn_start?", btn_start, MRB_ARGS_REQ(1));
}
