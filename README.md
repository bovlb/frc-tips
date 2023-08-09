# FRC tips

In the course of volunteering with an FRC team (and at various events), I see the same problems come around again and again.  Some of them have excellent resources already available to provide help; others take a little digging.

This project is a small collection of tips I've gathered to save redoing the same research effort.  Largely I'm just repeating stuff other people already said.  Example code is all in Java.

* [CAN bus](can-bus/): What is my utilization?  How much is too much?  How do I fix it?
* [Ramps](ramps/): How do I stop my robot from falling over when they drive too fast?
* [Coast mode](coast-mode/): How do I make my robot stop, stay stopped, and yet be easy to move?
* [Burnout](burnout/): How do you stop your motors from burning out?
* [Safety Captain](safety/): Help!  I just got appointed Safety Captain.  What do I do now?
* [Commands](commands/): Short guide to WPILIB commands, including [lambda functions](commands/lambda.md), and [CommandScheduler](commands/commandscheduler.md)
* [Links](links/): What are some useful resources for FRC?

I decided to put this together as a Github repository, partly so I could incorporate code files if I needed to, but mostly to make it easier for others to correct my inevitable mistakes.

Suggestions I have received for future notes:
* How to reset and persist motor controllers
* Some swerve bot gotchas - see [example swervebot](https://github.com/wpilibsuite/allwpilib/tree/main/wpilibjExamples/src/main/java/edu/wpi/first/wpilibj/examples/swervebot)
* Mecanum Drive gotchas.
* How to add your first autonomous routine, including for non-command robots
* Checking for errors (e.g. CAN bus devices).  Retrying?
* How should I configure and use IP addresses? (see [IP Configurations](https://docs.wpilib.org/en/stable/docs/networking/networking-introduction/ip-configurations.html))  How should I wire the Ethernet on the robot?
* Current limits and voltage compensation
* How to debug "No robot code"
* Example code that uses all commands stuff