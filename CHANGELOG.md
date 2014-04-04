## Version 339
#### Aircraft Version 31
- Arcade mode is now easier
- Fixed clientside emitter error

## Version 338
#### Aircraft
- Added maintenance station

## Version 337
#### Aircraft
- Fixed helicopter thrust being too high at lower tickrate
- Fixed aircraft RPM being higher at lower tickrate
- Fixed wheeled aircraft behaving weird
- Added menu option to disable damage
- Added option to lower volume
- Fixed camera when aircraft has no weapons (closes #89)
- Changed key smoothing factor (speed 3.5 instead of 5)
- Added option to disable damage (closes #86)

## Version 334
#### Aircraft
- Fixed #82
- Added 'Arcade Mode'
- Lowered sensitivity a little
- Removed WZ-10 models
- Changed camera and switch weapon buttons to right mouse and F, respectively

## Version 332
#### Aircraft:
- Player no longer ejects after entering (closes #46)
- Removed joystick debug MsgN call (closes #81)
- Clientside think no longer runs when Initialize failed (closes #58)
- Joystick buttons now keep working after they have been pressed (closes #79)
- Joystick buttons now work for clientside events (closes #44)
- Added gatling gun damage setting (closes #76)
- realism slider (closes #75)
- Fixed bullets colliding with aircraft (closes #74)
- Fixed weapon spam after aircraft crashes (issue 73)
- Fixed issue 71 (I guess?)
- Tweaked autorotation (issue 72)
- Rotor sound can now be heard further away
- Removed duplicate models
#### SWEPs:
- Fixed GMod camera not being able to rotate
- Removed data/WAC SWEPs (now in lua/wac/weapons)
