window_root "~/code/ss/$SVC"

new_window "code"

split_h 20
select_pane 1
split_v 20
split_h 50

run_cmd "enl_venv" 1
run_cmd "enl_venv" 2
run_cmd "enl_venv" 3
run_cmd "enl_venv" 4
select_pane 1
