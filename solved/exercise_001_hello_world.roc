# Oh no, this is supposed to print "Hello world!" but it needs
# your help.
#
# In Roc, the main function needs to be given to the platform
# for it to be executed.
#
# A function is provided to the platform in the header like so:
#
# ```roc
# app [function_name] {
#    pf: "https://..../basic-cli"
# }
# ```
#
# Perhaps knowing this will help solve the errors we're getting
# with this little program?
#
app [main!] {
    pf: platform "../../basic-cli/platform/main.roc",
}

import pf.Stdout

main! = |_|
    Stdout.line!("Hello world!")
