FUNCTION ZSDI_GETSTATUS_RFC
  IMPORTING
    VALUE(I_COMMAND) TYPE RSODCHAVL OPTIONAL
  EXPORTING
    VALUE(E_MESSAGE) TYPE RSODCHAVL.



*convert input command to internal table
split I_COMMAND at space into table data(lt_command).

if lines( lt_command ) = 0.
    e_message = |Unsupported Command|.
elseif lt_command[ 1 ] = '/start'.
    concatenate '<b>SAP BW process chain manipulation bot</b>'
                cl_abap_char_utilities=>cr_lf
                '================='
                cl_abap_char_utilities=>cr_lf
                'Please, use one of the following commands:'
                cl_abap_char_utilities=>cr_lf
                '/start returns this message'
                cl_abap_char_utilities=>cr_lf
                '/status returns current chains status'
    into e_message.
elseif lt_command[ 1 ] = '/status'.
*    select last log_id for requested process chain
    select chain_id as cname, datum as cdate, zeit as ctime, analyzed_status from rspclogchain as a
        join zbw_ers_chain as b on a~chain_id = b~chain
        into table @data(lt_log)
        order by datum descending,
                 zeit descending.
    delete adjacent duplicates from lt_log comparing cname.

*    construct returning message
    loop at lt_log into data(ls_log).
        e_message = e_message && |Process Chain <b>| && ls_log-cname && |</b>| && cl_abap_char_utilities=>cr_lf.
        e_message = e_message && |Last Run: Status | && ls_log-analyzed_status && |, Start Date/Time: | && ls_log-cdate && | | && ls_log-ctime && cl_abap_char_utilities=>cr_lf.
    endloop.
else.
    e_message = |Unsupported Command | && lt_command[ 1 ].
endif.

ENDFUNCTION.
