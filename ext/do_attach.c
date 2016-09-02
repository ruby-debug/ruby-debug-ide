#include "do_attach.h"

static const char *_command_to_eval;

static int
__check_gc(void)
{
    if (rb_during_gc()) {
        fprintf(stderr, "Can not connect during garbage collection phase. Please, try again later.\n");
        return 1;
    }
    return 0;
}

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
    if (__check_gc())
        return;
    __func_to_set_breakpoint_at();
//    rb_eval_string_protect(_command_to_eval, NULL); // TODO pass something more useful than NULL
}

int
start_attach(const char* command)
{
    rb_eval_string("puts 'bla bla bla'");
    _command_to_eval = command;
    if (__check_gc())
        return 1;
    rb_global_variable((VALUE *) _command_to_eval);
    rb_add_event_hook(__catch_line_event, RUBY_EVENT_LINE, (VALUE) NULL);
    return 2323;
}
