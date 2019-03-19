window_root "~/code/ss/$SVC"

new_window "code"

split_h 20
select_pane 1
split_v 20
split_h 50

run_cmd "dock" 1
run_cmd "dock" 2
run_cmd "dock" 3
run_cmd "dock" 4
