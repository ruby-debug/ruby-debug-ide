#ifndef __DO_ATTACH_H__
#define __DO_ATTACH_H__

#include <ruby.h>
#include <ruby/debug.h>
#include <stdio.h>

int start_attach(const char *command);

#endif //__DO_ATTACH_H__