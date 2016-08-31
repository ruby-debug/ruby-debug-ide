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
__catch_line_event(rb_event_flag_t evflag, VALUE data, VALUE self, ID mid, VALUE klass)
{
    (void)sizeof(evflag);
    (void)sizeof(self);
    (void)sizeof(mid);
    (void)sizeof(klass);

    rb_remove_event_hook(__catch_line_event);
    if (__check_gc())
        return;
    rb_eval_string_protect(_command_to_eval, NULL); // TODO pass something more useful than NULL
}

void
start_attach(const char* command)
{
    _command_to_eval = command;
    if (__check_gc())
        return;
    rb_global_variable((VALUE *) _command_to_eval);
    rb_add_event_hook(__catch_line_event, RUBY_EVENT_LINE, (VALUE) NULL);
}
