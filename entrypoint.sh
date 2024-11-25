#!/bin/sh
# Credit for the bulk of this entrypoint script goes to cornfeedhobo
# Source is https://github.com/cornfeedhobo/docker-monero/blob/master/entrypoint.sh
set -e

# https://www.getmonero.org/press-kit/ + https://www.asciiart.eu/image-to-ascii
cat <<"EOF"
                                                                                         
           ++++++++++++                                                                             
        ++++++++++++++++++                                                                          
       ++++++++++++++++++++                                                                         
      +++  ++++++++++++ ++++                                                                        
     ++++   ++++++++++  +++++    ###    ###   ########  ###    ##  ####### ########   #######       
     ++++     ++++++    +++++    ####  ####  ##     ### #####  ##  ##      ###   ##  ##     ###     
     ++++   #   ++   #  +++++    #### #####  ##      ## ###### ##  ####### ######## ###      ##     
     ++++   ###    ###  +++++   ### #### ### ##     ### ### #####  ##      ###  ##   ##     ###     
            ##########          ##  ###   ##  ########  ###   ###  ####### ###   ##   ########      
       ####################                                                                         
        ##################                   monerod: The Monero Daemon                                                       
           ############                      version: VERSION_NUMBER                                                       
                ##                                                                                  
                                                                                                                                                                                                    
EOF

# Set require --non-interactive flag
set -- "monerod" "--non-interactive" "$@"

# Execute the command as the monero user
exec "$@"
