# TSync - RFID Terminal SW Sync
This repository is periodically synced to the individual terminals that make up the RFID tracking portion of Jumbo's Maker Network.

When setting up the repository in the individual terminals, 2 local files are required:

sid.txt
  content - the number correlating to that terminals station ID
  #

.gitignore
  content - a reference to sid.txt so that it does not sync to the git and become overwritten with an incorrect SID.
  /sid.txt
  


