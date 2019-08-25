/*
    rprint.c -- print range of lines with optional context

    Author: Vladimir Dinev
    vld.dinev@gmail.com
    2019-08-25
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include <stdbool.h>

#define OPT_START           '-'
#define DFEAULT_NUM_WIDTH   8
#define DEFAULT_FIRST_LINE  1
#define MAX_LINE_LEN_WITH_0 1024
#define MAX_LINE_LEN_CH     (MAX_LINE_LEN_WITH_0-1)
#define end_of(arr)         (sizeof((arr))/sizeof((*arr)))

typedef struct {
    int first, prev, next, last, context, width;
    const char * start, * back, * fwd, * nested, * fname;
    bool silent, flength, end;
    FILE * file;
} arg_vals;

static const char prog_version[] = "v1.2";
static const char prog_name[]    = "rprint";

static void rprint(arg_vals * args);
static void print_output(arg_vals * args, int line_num, int read);
static int read_string(char * buff, int limit, FILE * file);
static int get_all_lines(FILE * file);
static int get_str_start_back_fwd(arg_vals * args, int * o_back, int * o_fwd);
static int get_str_back_fwd(arg_vals * args, int * o_fwd);
static const char * next(
    const char * first, const char * second, const char * where,
    const char ** out_addr
    );
static int get_nested_or_quit(arg_vals * args, int start_line);
static int find_nested(arg_vals * args);
static void equit(const char * msg, ...);
static FILE * lp_fopen(const char * fname);
static void lp_fclose(FILE * file);

#include "options.imp"

static char line[MAX_LINE_LEN_WITH_0];

int main(int argc, char * argv[])
{
#define call_and_rewind(...) __VA_ARGS__; rewind(args->file)
    if (argc > 1)
    {
        arg_vals args_, * args = &args_;
        memset(args, 0, sizeof(*args));
        args->first = DEFAULT_FIRST_LINE;
        args->width = DFEAULT_NUM_WIDTH;

        get_arg_vals(argc, argv, args);

        args->file = lp_fopen(args->fname);

        int back, fwd;
        if (args->flength)
            printf("%d\n", get_all_lines(args->file));
        else
        {

            if (args->start)
            {
                int start;
                start = call_and_rewind(
                    get_str_start_back_fwd(args, &back, &fwd));

                args->first = (back) ? back : start;

                int new_last = (start < fwd) ? fwd : start;
                if (args->last < new_last)
                    args->last = new_last;
            }
            else if (args->back || args->fwd)
            {
                back = call_and_rewind(get_str_back_fwd(args, &fwd));

                if (args->last < args->first)
                    args->last = args->first;

                if (args->last < fwd)
                    args->last = fwd;

                if (back && back < args->first)
                    args->first = back;
            }
            rprint(args);
        }
        lp_fclose(args->file);
    }
    else
        print_help(EXIT_FAILURE);

    return 0;
#undef call_and_rewind
}

static int get_str_start_back_fwd(arg_vals * args, int * o_back, int * o_fwd)
{
    int read;
    int i, start, back, fwd;
    const char * str_start = args->start;
    const char * str_back = args->back;
    const char * str_fwd = args->fwd;
    const char * str_nested = args->nested;

    i = start = back = fwd = 0;
    while ((read = read_string(line, MAX_LINE_LEN_WITH_0, args->file)))
    {
        ++i;
        if (strstr(line, str_start))
        {
            start = i;
            break;
        }

        if (str_back && strstr(line, str_back))
            back = i;
    }

    if (str_fwd)
    {
        while ((read = read_string(line, MAX_LINE_LEN_WITH_0, args->file)))
        {
            ++i;
            if (strstr(line, str_fwd))
            {
                fwd = i;
                break;
            }
        }

        if (str_nested)
            fwd += get_nested_or_quit(args, i);
    }
    else if (str_nested)
    {
        args->fwd = args->start;
        fwd = start + get_nested_or_quit(args, start);
    }

    *o_back = back;
    *o_fwd = fwd;
    return start;
}

static int get_str_back_fwd(arg_vals * args, int * o_fwd)
{
    int first = args->first;
    const char * str_back = args->back;
    const char * str_fwd = args->fwd;
    const char * str_nested = args->nested;
    int i, back, fwd, read;

    i = 1;
    back = fwd = 0;
    while (i < first)
    {
        read = read_string(line, MAX_LINE_LEN_WITH_0, args->file);
        if (read)
        {
            if (str_back && strstr(line, str_back))
                back = i;
        }
        else
            break;
        ++i;
    }

    if (str_fwd)
    {
        while (i <= first)
        {
            read = read_string(line, MAX_LINE_LEN_WITH_0, args->file);
            if (!read)
                break;
            ++i;
        }

        if (read)
        {
            while (read_string(line, MAX_LINE_LEN_WITH_0, args->file))
            {
                if (strstr(line, str_fwd))
                {
                    fwd = i;
                    break;
                }
                ++i;
            }
        }

        if (str_nested)
            fwd += get_nested_or_quit(args, i);
    }

    *o_fwd = fwd;
    return back;
}

static const char * next(
    const char * first, const char * second, const char * where,
    const char ** out_addr
    )
{
    static const char ambiguous[] = "";
    const char * ret = ambiguous;
    const char * a = strstr(where, first);
    const char * b = strstr(where, second);

    if (!a && !b)
        ret = NULL;
    else if (a && !b)
    {
        ret = first;
        *out_addr = a;
    }
    else if (!a && b)
    {
        ret = second;
        *out_addr = b;
    }
    else if (a < b)
    {
        ret = first;
        *out_addr = a;
    }
    else if (a > b)
    {
        ret = second;
        *out_addr = b;
    }

    return ret;
}

static int get_nested_or_quit(arg_vals * args, int start_line)
{
    int nested = find_nested(args);

    if (nested < 0)
        equit("no proper nesting from line %d", start_line);

    return nested;
}

static int find_nested(arg_vals * args)
{
    const char * first = args->fwd;
    const char * second = args->nested;
    int len_first = strlen(first);
    int len_second = strlen(second);
    const char * str_found, * str_tmp;

    int nested = 0;
    int lines = 0;
    do
    {
        str_found = strstr(line, first);
        str_tmp = (str_found) ? str_found : line;
        do
        {
            str_found = next(first, second, str_tmp, &str_tmp);
            if (str_found)
            {
                if (str_found == first)
                {
                    ++nested;
                    str_tmp += len_first;
                }
                else if (str_found == second)
                {
                    --nested;

                    if (nested <= 0)
                        goto out;

                    str_tmp += len_second;
                }
                else
                    equit("ambiguous nesting");
            }
        } while (str_found);

        ++lines;
    } while (read_string(line, MAX_LINE_LEN_WITH_0, args->file));

out:
    return (!nested) ? lines : -1;
}

static void rprint(arg_vals * args)
{
    int first           = args->first;
    int prev            = args->prev;
    int next            = args->next;
    int last            = args->last;
    int context         = args->context;
    bool end            = args->end;
    FILE * file         = args->file;

    if (!last)
       last = first;

    first = first - prev - context;
    if (first < DEFAULT_FIRST_LINE)
        first = DEFAULT_FIRST_LINE;

    last = last + next + context;

    if (last >= first)
    {
        for (int i = 1; i < first; ++i)
        {
            if (!read_string(line, MAX_LINE_LEN_WITH_0, file))
                return;
        }

        int read;
        if (end)
        {
            int lines = first;
            while ((read = read_string(line, MAX_LINE_LEN_WITH_0, args->file)))
            {
                print_output(args, lines, read);
                ++lines;
            }
        }
        else
        {
            for (int i = first; i <= last; ++i)
            {
                read = read_string(line, MAX_LINE_LEN_WITH_0, file);
                if (read)
                    print_output(args, i, read);
                else
                    break;
            }
        }
    }
    else
        equit("last less than first");
}

static void print_output(arg_vals * args, int line_num, int read)
{
    if (args->silent)
        printf("%s", line);
    else
        printf("%-*d%s", args->width, line_num, line);

    if (MAX_LINE_LEN_WITH_0-1 == read &&
        line[MAX_LINE_LEN_WITH_0-1] != '\n')
        printf("!--- line is cut because too long ---!");

    putchar('\n');
}

static int read_string(char * buff, int limit, FILE * file)
{
    int read = 0;
    int last = limit-1;

    for (int ch = fgetc(file); ch != EOF; ch = fgetc(file))
    {
        if (read < last)
        {
            if ('\n' == ch)
                ch = '\0';

            buff[read++] = ch;

            if ('\0' == ch)
                break;
        }
        else
        {
            while (ch != EOF && ch != '\n' && ch != '\0')
                ch = fgetc(file);
            break;
        }
    }

    buff[read] = '\0';
    return read;
}

static int get_all_lines(FILE * file)
{
    int lines = 0;
    for (int ch = fgetc(file); ch != EOF; ch = fgetc(file))
    {
        if ('\n' == ch)
            ++lines;
    }

    return lines;
}

static void equit(const char * msg, ...)
{
    va_list args;
    va_start(args, msg);
    fprintf(stderr, "error: ");
    vfprintf(stderr, msg, args);
    va_end (args);
    fputc('\n', stderr);
    exit(EXIT_FAILURE);
}

static FILE * lp_fopen(const char * fname)
{
    FILE * file = stdin;

    if (fname)
    {
        file = fopen(fname, "r");

        if (!file)
            equit("can't open file < %s >", fname);
    }

    return file;
}

static void lp_fclose(FILE * file)
{
    if (file != stdin)
        fclose(file);
}
