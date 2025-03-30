#!/bin/sh


# https://www.getmonero.org/press-kit/ + https://www.asciiart.eu/image-to-ascii
cat <<"EOF"
                                                                                         
           ++++++++++++                                                                             
        ++++++++++++++++++                                                                          
       ++++++++++++++++++++                                                                         
      +++  ++++++++++++ ++++                                                                        
     ++++   ++++++++++  +++++    ###    ###   ########  ###    ##  ####### ########   #######       
     ++++     ++++++    +++++    ####  ####  ##     ### #####  ##  ##      ###   ##  ##     ###     
     ++++       ++      +++++    #### #####  ##      ## ###### ##  ####### ######## ###      ##     
     ++++   ###    ###  +++++   ### #### ### ##     ### ### #####  ##      ###  ##   ##     ###     
            ##########          ##  ###   ##  ########  ###   ###  ####### ###   ##   ########      
       ####################                                                                         
        ##################                   monerod: The Monero Daemon                                                       
           ############                      version: VERSION_NUMBER                                                       
                ##                                                                                  
                                                                                                                                                                                                    
EOF

echo "=========================================================================================="
echo "Build Information"
echo "platform: PLATFORM"
echo "version:  $(/app/monero/bin/monerod --version)"
echo "sha256:   $(sha256sum /app/monero/bin/monerod)"
echo "puid:     PUID"
echo "pgid:     PGID"
echo "=========================================================================================="


# Set require --non-interactive flag
set -- "/app/monero/bin/monerod" "--non-interactive" "$@"

# Execute the command as the monero user
exec "$@"
