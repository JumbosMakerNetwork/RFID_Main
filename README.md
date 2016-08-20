# TSync - RFID Terminal SW Sync
This repository is periodically synced to the individual terminals that make up the RFID tracking portion of Jumbo's Maker Network.

When setting up the repository in the individual terminals, you must create sid.txt and its only content should be the station ID for that terminal. .gitignore references that document and later updates will not overwrite that document. This enables the Station Identification number to remain unchanged locally while software updates get pushed to all terminals. 



