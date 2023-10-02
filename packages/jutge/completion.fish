set -l commands help download test upload check db new

complete -c jutge -f
complete -c jutge -n "__fish_seen_subcommand_from upload download test check new" -F

complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "download" -d 'Download problems'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "test" -d 'Test problems'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "upload" -d 'Upload problems'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "check" -d 'Check problems'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "db" -d 'Database commands'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "new" -d 'Create new problem'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -a "help" -d 'Print a short help text and exit'

# Database subcommands
complete -c jutge -n "__fish_seen_subcommand_from db" \
    -a "print" -d 'Print database entries'
complete -c jutge -n "__fish_seen_subcommand_from db" \
    -a "add" -d 'Add database entries'
complete -c jutge -n "__fish_seen_subcommand_from db" \
    -a "query" -d 'Query database entries'
complete -c jutge -n "__fish_seen_subcommand_from db" \
    -a "import" -d 'Import problems to database'
complete -c jutge -n "__fish_seen_subcommand_from add query import" -F

# Upload command
complete -c jutge -n "__fish_seen_subcommand_from upload" \
    -l code -s c -r -d 'Problem code'
complete -c jutge -n "__fish_seen_subcommand_from upload" \
    -l annotation -s a -x -d 'Annotation field'
complete -c jutge -n "__fish_seen_subcommand_from upload" \
    -l compiler -s c -d 'Compiler' -x -a "(jutge --completion-bash upload --compiler)"
complete -c jutge -n "__fish_seen_subcommand_from upload" \
    -l check -s c -d 'Check veredict after upload'

# New subcommand
complete -c jutge -n "__fish_seen_subcommand_from new" \
    -l dry-run -d 'Do not create file, just print the filename'

# Test subcommand
complete -c jutge -n "__fish_seen_subcommand_from test" \
    -l code -s c -d 'Problem code' -r
complete -c jutge -n "__fish_seen_subcommand_from test" \
    -l no-download -d 'Do not download files'

# Download subcommand
complete -c jutge -n "__fish_seen_subcommand_from download" \
    -l overwrite -d 'Overwrite files'

# These are simple options that can be used everywhere.
complete -c jutge -l help -d 'Print a short help text and exit'

complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l version -d 'Print a short version string and exit'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l work-dir -r -d 'Directory to save jutge files'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l concurrency -x -d 'Maximum concurrent routines'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l regex -x -d 'Regular expression used to validate and find problem codes in filenames'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l user -x -d 'Username'
complete -c jutge -n "not __fish_seen_subcommand_from $commands" \
    -l pass -x -d 'Password'
