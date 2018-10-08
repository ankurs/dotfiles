window_root "~/code"

new_window "watch"

split_h 70
split_h 50
select_pane 1
split_v 50

run_cmd "watch -n 30 'source ~/.profile; show_zone HPA'" 1
run_cmd "watch -n 30 'source ~/.profile; show_zone'" 2
run_cmd "watch -n 30 'source ~/.profile; show_ms HPA'" 3
run_cmd "watch -n 30 'source ~/.profile; show_ms'" 4
