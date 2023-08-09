# CommandScheduler

When you are first taught to program, you are usually shown what is called the "imperative" style.  That means that you are in control of what happens when.  In a command-based robot, you have to use an "event-driven" style.  You must learn how to break your code up into small pieces that execute quickly and rely on the `CommandScheduler` to call them at the right time.  The `CommandScheduler` will manage commands, calling their four lifecycle methods (`initialize`, `execute`, `isFinished`, `end`).  It will also call the `periodic` methods of your subsystems and test any triggers you may have (mostly this will be joystick buttons).  It is also responsible for managing the requirements of two commands, so two commands with overlapping requirements are never scheduled at the same time.

There are a number of ways to invoke the `CommandScheduler`:

## `CommandScheduler.getInstance().run()`
* This makes the `CommandScheduler` perform its main loop for subsystems, triggers, and commands.
* This should be called from `Robot.robotPeriodic` and nowhere else.
* Most commands will not run while the robot is disabled, so will be automatically cancelled.

## `Trigger` methods
* When you set up a `Trigger` with a `Command`, then the `CommandScheduler` will automatically test the trigger.  When the trigger activates, it will call `schedule` on the command.
* You're probably already using `Trigger`s in the form of joystick buttons.

## `Command.schedule()`
* Attempts to add the command to the list of scheduled commands.
* If a scheduled command has overlapping requirements, then either the other commands will be cancelled or if the other commands are non-interruptible (rare), then the attempt will fail.
* This should be called by `Robot.automomousInit` to set the autonomous command.
* It's fairly rare for teams to call `schedule` in any other context.  The main example is a pattern where you create a state machine by having each state be a separate command, with all of them sharing the same requirements.  Outside that, if you find yourself wanting to call this anywhere else, you're probably doing something wrong.
* Calls to `schedule` from inside a command lifecycle method are deferred until after all the scheduled commands have been run.

## `Command.cance()`
* Unschedules the command
* May cause a default command to be scheduled
* It is common to call `cancel` on the autonomous command inside `Robot.teleopInit`.
* There is also `CommandScheduler.getInstance().cancelAll
* Calls to `cancel` from inside a command lifecycle method are deferred until after all the scheduled commands have been run, and after all the pending schedules have been scheduled.
* It's pretty rare to have to call this.  If you find yourself wanting to call this anywhere else, you're probably doing something wrong.

## See also
* https://docs.wpilib.org/en/stable/docs/software/commandbased/command-scheduler.html

<figure style="width: 100%;"><img style="width: 100%" src="commandscheduler.png" alt="Workflow of CommandScheduler" />
<figcaption>This shows the workflow of the CommandScheduler in Java.  The C++ implemention has almost identical behaviour.  This diagram dooes not show command event methods</figcaption>
</figure>