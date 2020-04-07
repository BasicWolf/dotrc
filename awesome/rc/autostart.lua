loadrc("util", "zawesome/util")

-- run_once("glipper", nil, ".*glipper")
run_once("xscreensaver", "-no-splash", ".*xscreensaver.*", nil)
run_once("vivaldi", nil, ".*vivaldi-bin.*")
run_once("emacs")
run_once("Telegram", nil, ".*Telegram.*")

hostname = io.popen("uname -n"):read()

if hostname == "z" then
   run_once("thunderbird")
   run_once("dropbox start")
end
