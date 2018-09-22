Bartering Tweaks Changelog
=======
# 1.2.0.1
* Moved main bulk of code into a sub-goal.
* Tweaked attitude removal / persuasion re-applying.
* Added registered LeaderLib Mod Menu dialogs to a "blacklist", so persuasion/attitude sharing isn't set when opening a settings menu.

# 1.1.0.2
* Quick hotfix to fix the settings book not being movable. 

# 1.1.0.0
* Added a Bartering Tweaks settings book. It should automatically be added to each user upon loading a save, or when playing a new game.


# 1.0.6.1
* Fixed a typo that prevented a sneaking flag from being cleared from party members, preventing them from removing the party's sneaking status.

# 1.0.5.0
* Fixes for sharing attitude with characters that have Stench. Note that your attitude bonuses won't be visible on your current character until you switch between characters in the trade menu.

# 1.0.1.1
* Added a missing localization string (Stats_LLBARTER_PersuasionBonus => Party Persuasion).
* Added a safety check for clearing Persuasion bonuses from other owned characters when dialog ends. Note that your persuasion bonuses will apply to all owned characters while one of them is in dialog - this is intended, since you may decide to switch characters and start up another dialog.

# 1.0.1.0
* Added persuasion sharing in dialog & trade, enabled in the Features sub-menu.
* Added a "Remove All Bonuses" debug command for hosts. It removes every shared persuasion/bartering/attitude bonus on all players.

# 1.0.0.7
* Reworked attitude-sharing so it applies to all user-owned characters. Still a little experimental.

# 1.0.0.5
* Initial Release