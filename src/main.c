#include <kos.h>
#include <dc/sound/sound.h>
#include <mruby.h>
#include <mruby/irep.h>
#include "dckos.h"

/* These macros tell KOS how to initialize itself. All of this initialization
   happens before main() gets called, and the shutdown happens afterwards. So
   you need to set any flags you want here. Here are some possibilities:

   INIT_NONE        -- don't do any auto init
   INIT_IRQ     -- Enable IRQs
   INIT_THD_PREEMPT -- Enable pre-emptive threading
   INIT_NET     -- Enable networking (doesn't imply lwIP!)
   INIT_MALLOCSTATS -- Enable a call to malloc_stats() right before shutdown

   You can OR any or all of those together. If you want to start out with
   the current KOS defaults, use INIT_DEFAULT (or leave it out entirely). */
KOS_INIT_FLAGS(INIT_DEFAULT | INIT_MALLOCSTATS);

/* You can safely remove this line if you don't use a ROMDISK */
extern uint8 romdisk[];

extern const uint8_t dreampresent_bytecode[]; // compiled ruby code

void print_device_info(int i) {
    int PX_PER_LINE = 640;
    maple_device_t *dev;
    for(int i = 0; i < 4 ; i ++) {
        // for(int j = 0; j < 4; j++) {
            int j = 0;
            dev = maple_enum_type(i, 0x1000000);
            if(dev) {
                int x = 10;
                int y = (j) * 24;
                char content[1000];
                sprintf(content, "Device at %d", j);
  bfont_draw_str_ex(vram_s + x + (y * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                y += 24;
                sprintf(content, "%d, %d", i, 0);
  bfont_draw_str_ex(vram_s + x + (y * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                y += 24;
                sprintf(content, "%s", dev->info.product_name);
  bfont_draw_str_ex(vram_s + x + (y * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                y += 24;
                sprintf(content, "%lx", dev->info.functions);
  bfont_draw_str_ex(vram_s + x + (y * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);

                maple_device_t *fcontroller;
                for(int i = 0; i < 4; i++) {
                    fcontroller = maple_enum_type(0, MAPLE_FUNC_CONTROLLER);
                    sprintf(content, "Controller: %s", fcontroller->info.product_name);
                    bfont_draw_str_ex(vram_s + 80 + (200 * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                    // TODO: this limits the support to Dreamcast Fishing Controller. Maybe there are other fishing controllers?
                    // char* product_name = "Dreamcast Fishing Controller";
                    char* PRODUCT_NAME = "Dreamcast Controller";
                    sprintf(content, "strncmp: %d", strncmp(fcontroller->info.product_name, PRODUCT_NAME, strlen(PRODUCT_NAME)));
                    bfont_draw_str_ex(vram_s + 80 + (230 * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                    if(fcontroller && strncmp(fcontroller->info.product_name, PRODUCT_NAME, strlen(PRODUCT_NAME)) == 0) {
                        while(1) {
                            cont_state_t *state = (cont_state_t *)maple_dev_status(fcontroller);
                            sprintf(content, "ltrigger: %d, rtrigger: %d, buttons: %ld", state->ltrig, state->rtrig, state->buttons);
                            bfont_draw_str_ex(vram_s + 80 + (260 * PX_PER_LINE), PX_PER_LINE, 0xFFFF, 0x00000000, (sizeof (uint16)) << 3, 1, content);
                        }
                    }
                }
            }
        // }
    }
}

int main(int argc, char **argv) {
    vid_set_mode(DM_640x480_VGA, PM_RGB565);
    //vid_set_mode(DM_640x480_NTSC_IL, PM_RGB565);
    snd_init();

    // print_device_info(1);

    // while(1);

    mrb_state *mrb = mrb_open();
    if (!mrb) { return 1; }

    struct RClass *dc_kos = mrb_define_module(mrb, "DcKos");

    define_module_functions(mrb, dc_kos);

    mrb_load_irep(mrb, dreampresent_bytecode);

    print_exception(mrb);

    mrb_close(mrb);

    return 0;
}
