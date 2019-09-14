#!/bin/bash

G_TEST_DIR="./tests"
G_TEST_FILE_NAME="test_file.txt"
G_TEST_FILE="$G_TEST_DIR/$G_TEST_FILE_NAME"
G_TMP_FILE="tmp_result.txt"
G_BINARY=""
G_RESULT_FILE=""

function set_g_result_file
{
    G_RESULT_FILE="$G_TEST_DIR/$1"
}

function run_write
{
    local L_TEST_CASE="$1"
    "$G_BINARY" $L_TEST_CASE > "$G_TMP_FILE" 2>&1
}

function file_compare
{
    local L_RESULT_FILE="$1"
    local L_TEST_CASE="$2"

    diff "$G_TMP_FILE" "$L_RESULT_FILE"
    if [ "$?" -ne 0 ]; then
        echo "Failed test case:" "$L_TEST_CASE"
        echo "Result with file" "$L_RESULT_FILE" "differ"
        exit 1
    fi
}

function test_run_compare
{
    local L_TEST_CASE="$1"
    local L_RESULT_FILE="$G_RESULT_FILE"
    run_write "$L_TEST_CASE"
    file_compare "$L_RESULT_FILE" "$L_TEST_CASE"
}

function run_compare_with_test_file
{
    local L_TEST_CASE="$G_TEST_FILE $1"
    test_run_compare "$L_TEST_CASE"
}

function run_tests
{
    # rprint options
    local L_START_NUM_S="-s"
    local L_START_NUM_L="--start-num"
    local L_BACK_NUM_S="-b"
    local L_BACK_NUM_L="--back-num"
    local L_FORWARD_NUM_S="-f"
    local L_FORWARD_NUM_L="--forward-num"
    local L_UNTIL_S="-u"
    local L_UNTIL_L="--until"
    local L_CONTEXT_S="-c"
    local L_CONTEXT_L="--context"
    local L_START_STR_S="-S"
    local L_START_STR_L="--start-str"
    local L_BACK_STR_S="-B"
    local L_BACK_STR_L="--back-str"
    local L_FORWARD_STR_S="-F"
    local L_FORWARD_STR_L="--forward-str"
    local L_NESTED_S="-N"
    local L_NESTED_L="--nested"
    local L_END_S="-e"
    local L_END_L="--end"
    local L_WIDTH_S="-w"
    local L_WIDTH_L="--width"
    local L_QUIET_S="-q"
    local L_QUIET_L="--quiet"
    local L_LENGTH_S="-l"
    local L_LENGTH_L="--length"
    local L_HELP_S="-?"
    local L_HELP_L="--help"
    local L_VERSION_S="-v"
    local L_VERSION_L="--version"

    # normal use cases
    local L_TCASE_LEN_S="$L_LENGTH_S"
    local L_TCASE_LEN_L="$L_LENGTH_L"
    local L_RES_FILE_LEN="length.txt"

    local L_TCASE_EQ_S="$L_END_S $L_QUIET_S"
    local L_TCASE_EQ_L="$L_END_L $L_QUIET_L"
    local L_RES_FILE_EQ="$G_TEST_FILE_NAME"

    local L_TCASE_WFN_S="$L_WIDTH_S 2 $L_FORWARD_NUM_S 10"
    local L_TCASE_WFN_L="$L_WIDTH_L 2 $L_FORWARD_NUM_L 10"
    local L_RES_FILE_WFN="width_2.txt"

    local L_TCASE_SFN_S="$L_START_NUM_S 20 $L_FORWARD_NUM_S 2"
    local L_TCASE_SFN_L="$L_START_NUM_L 20 $L_FORWARD_NUM_L 2"
    local L_RES_FILE_SFN="start_forward_num_num.txt"

    local L_TCASE_SBN_S="$L_START_NUM_S 20 $L_BACK_NUM_S 2"
    local L_TCASE_SBN_L="$L_START_NUM_L 20 $L_BACK_NUM_L 2"
    local L_RES_FILE_SBN="start_back_num_num.txt"

    local L_TCASE_SC_S="$L_START_NUM_S 20 $L_CONTEXT_S 2"
    local L_TCASE_SC_L="$L_START_NUM_L 20 $L_CONTEXT_L 2"
    local L_RES_FILE_SC="start_context.txt"

    local L_TCASE_SU_S="$L_START_NUM_S 20 $L_UNTIL_S 30"
    local L_TCASE_SU_L="$L_START_NUM_L 20 $L_UNTIL_L 30"
    local L_RES_FILE_SU="start_until.txt"

    local L_TCASE_SUBFC_S="$L_START_NUM_S 20 $L_UNTIL_S 25 "
    L_TCASE_SUBFC_S+="$L_BACK_NUM_S 1 $L_FORWARD_NUM_S 1 $L_CONTEXT_S 2"
    local L_TCASE_SUBFC_L="$L_START_NUM_L 20 $L_UNTIL_L 25 "
    L_TCASE_SUBFC_L+="$L_BACK_NUM_L 1 $L_FORWARD_NUM_L 1 $L_CONTEXT_L 2"
    local L_RES_FILE_SUBFC="subfc_num.txt"

    local L_START_STR="while"
    local L_TCASE_S_STR_S="$L_START_STR_S $L_START_STR"
    local L_TCASE_S_STR_L="$L_START_STR_L $L_START_STR"
    local L_RES_FILE_S_STR="start_str.txt"

    local L_BACK_STR="const"
    local L_TCASE_SB_STR_S="$L_START_STR_S $L_START_STR "
    L_TCASE_SB_STR_S+="$L_BACK_STR_S $L_BACK_STR"
    local L_TCASE_SB_STR_L="$L_START_STR_L $L_START_STR "
    L_TCASE_SB_STR_L+="$L_BACK_STR_L $L_BACK_STR"
    local L_RES_FILE_SB_STR="start_back_str.txt"

    local L_FWD_STR="}"
    local L_TCASE_SF_STR_S="$L_START_STR_S $L_START_STR "
    L_TCASE_SF_STR_S+="$L_FORWARD_STR_S $L_FWD_STR"
    local L_TCASE_SF_STR_L="$L_START_STR_L $L_START_STR "
    L_TCASE_SF_STR_L+="$L_FORWARD_STR_L $L_FWD_STR"
    local L_RES_FILE_SF_STR="start_fwd_str.txt"

    local L_FWDN_STR="{"
    local L_NEST_STR="}"
    local L_TCASE_SFN_STR_S="$L_START_STR_S $L_START_STR "
    L_TCASE_SFN_STR_S+="$L_FORWARD_STR_S $L_FWDN_STR "
    L_TCASE_SFN_STR_S+="$L_NESTED_S $L_NEST_STR"
    local L_TCASE_SFN_STR_L="$L_START_STR_L $L_START_STR "
    L_TCASE_SFN_STR_L+="$L_FORWARD_STR_L $L_FWDN_STR "
    L_TCASE_SFN_STR_L+="$L_NESTED_L $L_NEST_STR"
    local L_RES_FILE_SFN_STR="start_fwd_nest_str.txt"

    local L_TCASE_SN_STR_S="$L_START_STR_S $L_FWDN_STR "
    L_TCASE_SN_STR_S+="$L_NESTED_S $L_NEST_STR"
    local L_TCASE_SN_STR_L="$L_START_STR_L $L_FWDN_STR "
    L_TCASE_SN_STR_L+="$L_NESTED_L $L_NEST_STR"
    local L_RES_FILE_SN_STR="start_nest_str.txt"

    local L_TCASE_SFNB_STR_S="$L_START_STR_S $L_START_STR "
    L_TCASE_SFNB_STR_S+="$L_FORWARD_STR_S $L_FWDN_STR "
    L_TCASE_SFNB_STR_S+="$L_NESTED_L $L_NEST_STR "
    L_TCASE_SFNB_STR_S+="$L_BACK_STR_S $L_BACK_STR"
    local L_TCASE_SFNB_STR_L="$L_START_STR_L $L_START_STR "
    L_TCASE_SFNB_STR_L+="$L_FORWARD_STR_L $L_FWDN_STR "
    L_TCASE_SFNB_STR_L+="$L_NESTED_L $L_NEST_STR "
    L_TCASE_SFNB_STR_L+="$L_BACK_STR_L $L_BACK_STR"
    local L_RES_FILE_SFNB_STR="sfnb_str.txt"

    local L_TCASE_NUM_STR_COMB_S="$L_START_NUM_S 11 $L_BACK_STR_S $L_BACK_STR "
    L_TCASE_NUM_STR_COMB_S+="$L_FORWARD_STR_S $L_FWDN_STR "
    L_TCASE_NUM_STR_COMB_S+="$L_NESTED_S $L_NEST_STR "
    L_TCASE_NUM_STR_COMB_S+="$L_CONTEXT_S 2 $L_BACK_NUM_S 1 $L_FORWARD_NUM_S 2"
    local L_TCASE_NUM_STR_COMB_L="$L_START_NUM_L 11 $L_BACK_STR_L $L_BACK_STR "
    L_TCASE_NUM_STR_COMB_L+="$L_FORWARD_STR_L $L_FWDN_STR "
    L_TCASE_NUM_STR_COMB_L+="$L_NESTED_L $L_NEST_STR "
    L_TCASE_NUM_STR_COMB_L+="$L_CONTEXT_L 2 $L_BACK_NUM_L 1 $L_FORWARD_NUM_L 2"
    local L_RES_FILE_NUM_STR_COMB="num_str_comb.txt"

    local L_TCASE_VERSION_S="$L_VERSION_S"
    local L_TCASE_VERSION_L="$L_VERSION_L"
    local L_RES_FILE_VERSION="version.txt"

    local L_TCASE_HELP_S="$L_HELP_S"
    local L_TCASE_HELP_L="$L_HELP_L"
    local L_RES_FILE_HELP="help.txt"

    # file cut outs
    local L_TCASE_SBN_CUT="$L_START_NUM_S 2 $L_BACK_NUM_S 10"
    local L_RES_FILE_SBN_CUT="sb_num_cut.txt"

    local L_TCASE_SC_CUT="$L_START_NUM_S 2 $L_CONTEXT_S 5"
    local L_RES_FILE_SC_CUT="sc_cut.txt"

    local L_TCASE_SFN_CUT="$L_START_NUM_S 41 $L_FORWARD_NUM_S 20"
    local L_RES_FILE_SFN_CUT="sf_num_cut.txt"

    # errors
    local L_TCASE_LAST_FIRST_ERR="$L_START_NUM_S 10 $L_UNTIL_S 5"
    local L_RES_FILE_LAST_FIRST_ERR="last_first_error.txt"

    local L_SECOND_FILE_NAME="hasfile"
    local L_TCASE_HAS_FILE_ERR="$L_SECOND_FILE_NAME"
    local L_RES_FILE_HAS_FILE_ERR="has_file.txt"

    local L_STR="string"
    local L_TCASE_NAN_ERR_SN="$L_START_NUM_S $L_STR"
    local L_TCASE_NAN_ERR_BN="$L_BACK_NUM_S $L_STR"
    local L_TCASE_NAN_ERR_FN="$L_FORWARD_NUM_S $L_STR"
    local L_TCASE_NAN_ERR_CN="$L_CONTEXT_S $L_STR"
    local L_TCASE_NAN_ERR_UN="$L_UNTIL_S $L_STR"
    local L_RES_FILE_NAN_ERR="nan_err.txt"

    # tables
    local L_TEST_CASE_TBL=(
        "$L_TCASE_LEN_S" "$L_TCASE_LEN_L"
        "$L_TCASE_EQ_S" "$L_TCASE_EQ_L"
        "$L_TCASE_WFN_S" "$L_TCASE_WFN_L"
        "$L_TCASE_SFN_S" "$L_TCASE_SFN_L"
        "$L_TCASE_SBN_S" "$L_TCASE_SBN_L"
        "$L_TCASE_SC_S" "$L_TCASE_SC_L"
        "$L_TCASE_SU_S" "$L_TCASE_SU_L"
        "$L_TCASE_SUBFC_S" "$L_TCASE_SUBFC_L"
        "$L_TCASE_S_STR_S" "$L_TCASE_S_STR_L"
        "$L_TCASE_SB_STR_S" "$L_TCASE_SB_STR_L"
        "$L_TCASE_SF_STR_S" "$L_TCASE_SF_STR_L"
        "$L_TCASE_SFN_STR_S" "$L_TCASE_SFN_STR_L"
        "$L_TCASE_SN_STR_S" "$L_TCASE_SN_STR_L"
        "$L_TCASE_SFNB_STR_S" "$L_TCASE_SFNB_STR_L"
        "$L_TCASE_NUM_STR_COMB_S" "$L_TCASE_NUM_STR_COMB_L"
        "$L_TCASE_VERSION_S" "$L_TCASE_VERSION_L"
        "$L_TCASE_HELP_S" "$L_TCASE_HELP_L"

        "$L_TCASE_SBN_CUT"
        "$L_TCASE_SC_CUT"
        "$L_TCASE_SFN_CUT"

        "$L_TCASE_LAST_FIRST_ERR"
        "$L_TCASE_HAS_FILE_ERR"
        "$L_TCASE_NAN_ERR_SN"
        "$L_TCASE_NAN_ERR_BN"
        "$L_TCASE_NAN_ERR_FN"
        "$L_TCASE_NAN_ERR_CN"
        "$L_TCASE_NAN_ERR_UN"
    )
    local L_TCASE_TBL_LEN="${#L_TEST_CASE_TBL[@]}"

    local L_RESULT_FILE_TBL=(
        "$L_RES_FILE_LEN" "$L_RES_FILE_LEN"
        "$L_RES_FILE_EQ" "$L_RES_FILE_EQ"
        "$L_RES_FILE_WFN" "$L_RES_FILE_WFN"
        "$L_RES_FILE_SFN" "$L_RES_FILE_SFN"
        "$L_RES_FILE_SBN" "$L_RES_FILE_SBN"
        "$L_RES_FILE_SC" "$L_RES_FILE_SC"
        "$L_RES_FILE_SU" "$L_RES_FILE_SU"
        "$L_RES_FILE_SUBFC" "$L_RES_FILE_SUBFC"
        "$L_RES_FILE_S_STR" "$L_RES_FILE_S_STR"
        "$L_RES_FILE_SB_STR" "$L_RES_FILE_SB_STR"
        "$L_RES_FILE_SF_STR" "$L_RES_FILE_SF_STR"
        "$L_RES_FILE_SFN_STR" "$L_RES_FILE_SFN_STR"
        "$L_RES_FILE_SN_STR" "$L_RES_FILE_SN_STR"
        "$L_RES_FILE_SFNB_STR" "$L_RES_FILE_SFNB_STR"
        "$L_RES_FILE_NUM_STR_COMB" "$L_RES_FILE_NUM_STR_COMB"
        "$L_RES_FILE_VERSION" "$L_RES_FILE_VERSION"
        "$L_RES_FILE_HELP" "$L_RES_FILE_HELP"

        "$L_RES_FILE_SBN_CUT"
        "$L_RES_FILE_SC_CUT"
        "$L_RES_FILE_SFN_CUT"

        "$L_RES_FILE_LAST_FIRST_ERR"
        "$L_RES_FILE_HAS_FILE_ERR"
        "$L_RES_FILE_NAN_ERR"
        "$L_RES_FILE_NAN_ERR"
        "$L_RES_FILE_NAN_ERR"
        "$L_RES_FILE_NAN_ERR"
        "$L_RES_FILE_NAN_ERR"
    )
    local L_RFILE_TBL_LEN="${#L_RESULT_FILE_TBL[@]}"

    # run table tests
    for (( i=0; i<"$L_TCASE_TBL_LEN"; ++i ));
    do
        set_g_result_file "${L_RESULT_FILE_TBL[$i]}"
        run_compare_with_test_file "${L_TEST_CASE_TBL[$i]}"
    done

    # run non-table tests
    local L_TEST_CASE=""
    set_g_result_file "no_args.txt"
    test_run_compare "$L_TEST_CASE"

    L_TEST_CASE="$G_TEST_FILE"
    set_g_result_file "file_only.txt"
    test_run_compare "$L_TEST_CASE"

    L_TEST_CASE="this_file_name_must_not_exist"
    set_g_result_file "cant_open_file_err.txt"
    test_run_compare "$L_TEST_CASE"
}

function clean_up
{
    rm "$G_TMP_FILE"
}

function main
{
    if [ "$#" -ne 1 ]; then
        echo "Use: $0 <path-to-test-binary>"
        exit 1
    fi

    G_BINARY="$1"
    run_tests
    clean_up
}

main $@
