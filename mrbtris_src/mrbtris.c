#include <kos.h>
#include <mruby.h>
#include <mruby/data.h>
#include <mruby/string.h>
#include <mruby/error.h>
#include <stdio.h>
#include <inttypes.h>

#define PACK_PIXEL(r, g, b) ( ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)  )

mrb_value clear_screen(mrb_state *mrb, mrb_value self) {
  int x = 0, y = 0;
  for(y = 0; y < 480 ; y ++ ) {
    for(x = 0; x < 640 ; x ++ ) {
      vram_s[x + y * 640] = PACK_PIXEL(0, 0, 0);
    }
  }

  return mrb_nil_value();
}

mrb_value put_pixel640(mrb_state *mrb, mrb_value self) {
  mrb_int x, y, r, g, b;
  mrb_get_args(mrb, "iiiii", &x, &y, &r, &g, &b);

  vram_s[x + y * 640] = PACK_PIXEL(r, g, b);

  return mrb_nil_value();
}

static mrb_value draw20x20_640(mrb_state *mrb, mrb_value self) {
  mrb_int x, y, r, g, b;
  mrb_get_args(mrb, "iiiii", &x, &y, &r, &g, &b);

  int i = 0, j = 0;

  if(r == 0 && g == 0 && b == 0) {
    for(i = 0; i < 20; i++) {
      for(j = 0; j < 20; j++) {
        vram_s[x+j + (y+i) * 640] = PACK_PIXEL(r, g, b);
      }
    }
  } else {
    int r_light = (r+128 <= 255) ? r+128 : 255;
    int g_light = (g+128 <= 255) ? g+128 : 255;
    int b_light = (b+128 <= 255) ? b+128 : 255;

    int r_dark = (r-64 >= 0) ? r-64 : 0;
    int g_dark = (g-64 >= 0) ? g-64 : 0;
    int b_dark = (b-64 >= 0) ? b-64 : 0;

    // TODO: implement lines and use them.
    for(j = 0; j < 20; j++) {
      vram_s[x+j + (y) * 640] = PACK_PIXEL(30, 30, 30);
      vram_s[x+j + (y+19) * 640] = PACK_PIXEL(30, 30, 30);
    }
    for(j = 1; j < 19; j++) {
      vram_s[x+j + (y+1) * 640] = PACK_PIXEL(r_light, g_light, b_light);
    }
    for(j = 2; j < 20; j++) {
      vram_s[x+j + (y+19) * 640] = PACK_PIXEL(r_dark, g_dark, b_dark);
    }
    for(i = 2; i < 19; i++) {
      vram_s[x + (y+i) * 640] = PACK_PIXEL(30, 30, 30);
      vram_s[x+1 + (y+i) * 640] = PACK_PIXEL(r_light, g_light, b_light);
      for(j = 2; j < 19; j++) {
        vram_s[x+j + (y+i) * 640] = PACK_PIXEL(r, g, b);
      }
      vram_s[x+19 + (y+i) * 640] = PACK_PIXEL(r_dark, g_dark, b_dark);
      //vram_s[x+19 + (y+i) * 640] = PACK_PIXEL(30, 30, 30);
    }
  }

  return mrb_nil_value();
}

static mrb_value waitvbl(mrb_state *mrb, mrb_value self) {
  vid_waitvbl();

  return mrb_nil_value();
}

static mrb_value get_button_state(mrb_state *mrb, mrb_value self) {
  maple_device_t *cont1;
  cont_state_t *state;
  if((cont1 = maple_enum_type(0, MAPLE_FUNC_CONTROLLER))){
    state = (cont_state_t *)maple_dev_status(cont1);
    //printf("controller state checked. %d\n", state->buttons);
    return mrb_fixnum_value(state->buttons);
  }
  return mrb_nil_value();
}

static mrb_value start_btn(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_START);
}

static mrb_value dpad_left(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_DPAD_LEFT);
}

static mrb_value dpad_right(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_DPAD_RIGHT);
}

static mrb_value dpad_up(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_DPAD_UP);
}

static mrb_value dpad_down(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_DPAD_DOWN);
}

static mrb_value btn_b(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_B);
}

static mrb_value btn_a(mrb_state *mrb, mrb_value self) {
  struct mrb_value state;
  mrb_get_args(mrb, "i", &state);

  return mrb_bool_value(mrb_fixnum(state) & CONT_A);
}

static mrb_value clear_score(mrb_state *mrb, mrb_value self) {
  char* clear_str = "Press START";
  bfont_draw_str(vram_s + 640 * 100 + 16, 640, 1, clear_str);

  return mrb_nil_value();
}

static mrb_value render_score(mrb_state *mrb, mrb_value self) {
  struct mrb_value score;
  mrb_get_args(mrb, "i", &score);
  char buf[20];
  snprintf(buf, 20, "Score: %8" PRId32, mrb_fixnum(score));
  bfont_draw_str(vram_s + 640 * 100 + 16, 640, 1, buf);

  return mrb_nil_value();
}

void define_game_module_functions(mrb_state* mrb, struct RClass* module) {
    mrb_define_module_function(mrb, module, "put_pixel640", put_pixel640, MRB_ARGS_REQ(5));
    mrb_define_module_function(mrb, module, "draw20x20_640", draw20x20_640, MRB_ARGS_REQ(5));
    mrb_define_module_function(mrb, module, "waitvbl", waitvbl, MRB_ARGS_NONE());

    mrb_define_module_function(mrb, module, "clear_score", clear_score, MRB_ARGS_NONE());

    mrb_define_module_function(mrb, module, "render_score", render_score, MRB_ARGS_REQ(1));

    mrb_define_module_function(mrb, module, "get_button_state", get_button_state, MRB_ARGS_NONE());

    mrb_define_module_function(mrb, module, "start_btn?", start_btn, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "dpad_left?", dpad_left, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "dpad_right?", dpad_right, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "dpad_up?", dpad_up, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "dpad_down?", dpad_down, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "btn_a?", btn_a, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "btn_b?", btn_b, MRB_ARGS_REQ(1));
    mrb_define_module_function(mrb, module, "clear_screen", clear_screen, MRB_ARGS_NONE());
}
