#include "attach.h"

static void
__func_to_set_breakpoint_at()
{
}

static void
__catch_line_event(rb_event_flag_t evflag, VALUE data, VALUE self, ID mid, VALUE klass)
{
    (void)sizeof(evflag);
    (void)sizeof(self);
    (void)sizeof(mid);
    (void)sizeof(klass);

    rb_remove_event_hook(__catch_line_event);
    if (rb_during_gc())
        return;
    __func_to_set_breakpoint_at();
}

int
start_attach()
{
    if (rb_during_gc())
        return 1;
    rb_add_event_hook(__catch_line_event, RUBY_EVENT_LINE, (VALUE) NULL);
    return 0;
}
