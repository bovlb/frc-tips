https://bovlb.github.io/frc-tips/commands/

 A programmer needs to be familiar with the various command-related tricks available in WPILIB.  I've divided them here into six groups:
* Command groups: Classes that take one or more commands and execute them all.
* Commands for use in groups: Commands that are useful when using command groups.
* Runnable wrappers: Classes that turn runnables (e.g. lambda expressions) into commands
* Command decorators: Methods provided by all commands to connect or change them.
* Running commands: How to run a command 
* Esoteric commands: Commands that are used only in specialized circumstances

These might seem a little complex and daunting, but the good news is that if you use them effectively your code will become simpler and easier to read.  There are many subtle gotchas about combining commands, and these help you to navigate them safely.

The scheduler will only run one command lifecycle method (`initialize`, `isFinished`, `execute`, `end`) or subsystem `periodic` at a time, so if you stay within this framework you don't have to worry about being thread-safe.

# Command groups

These classes group togather one or more commands and execute them all in some order.  They inherit the subsystem requirements of all of their sub-commands.  The sub-commands can be specified either in the constructor, or using `addCommands`.

* `SequentialCommandGroup`: Runs the sub-commands in sequence.
* `ParallelCommandGroup`: Runs the sub-commands in parallel.  Is finished when all sub-commands are finished.
* `ParallelDeadlineGroup`: Runs the sub-commands in parallel.  Is finished when the first command in the list is finished.
* `ParallelRaceGroup`: Runs the sub-commands in parallel.  Is finished when any sub-command is finished.

# Commands used in groups

The following commands are useful to build command groups.  Some of them take commands as arguments, and their subsystem requirements are inherited.

* `ConditionalCommand`: Given a condition (evaluated in `initialize`), runs one of two sub-commands.
* `SelectCommand`: Takes a mapping from keys to commands, and a key selector.  At `initialize`, the key selector is executed and then one of the sub-commands is run.
* `ProxyCommand`: This behaves exactly like the underlying command except that subsystem requirements are not inherited.
* `RepeatCommand`: Run the sub-command until it is finished, and then start it running again.
* `WaitCommand`: Insert a delay for a specific time. 
* `WaitUntilCommand`: Insert a delay untill some condition is met.

# Runnable wrappers

Here are some wrappers that turn runnables (e.g. lambda expressions) into commands.  These can be used in command groups, but they are also used in `RobotContainer` to create command on-the-fly.  When using these methods, please remember to add the subsystem(s) as the last parameter(s) to make subsystem requirements work correctly. 
* `InstantCommand`: The given runnable is used as the `initialize` method, there is no `execute` or `end`, and `isFinished` returns `true`.
* `RunCommand`: The given runnable is used as the `execute` method, there is no `initialize` or `end`, and `isFinished` returns `false`.  Often used with a decorator that adds an `isFinished` condition.
* `StartEndCommand`: The given runnables are used as the `initialize` and `end` methods, there is no `execute`m and `isFinished` returns `false`.  Commonly used for commands that start and stop motors.
* `FunctionalCommand`: Allows you you set all four life-cycle methods.  Not used if one of the above will suffice.

# Command decorators

These are methods that are provided by all `Command`s and allow you to create new commands that modify the underlying command in some way, or implicitly create command groups.  These can be used as an alternative way to write command groups, but are also used when creating commands on-the-fly in `RobotContainer`.

* `alongWith`: Runs the base command and the sub-command(s) in parallel ending when they are all finished (cf `ParallelCommandGroup`)
* `andThen`: Runs the base command and then the sub-commands or runnable (cd `SequentialCommandGroup`)
* `asProxy`: Blocks inheritance of subsystem requirements (cf `ProxyCommand`)
* `beforeStarting​`: Runs the sub-commands or runnable and then the base command (cf `SequentialCommandGroup`)
* `deadlineWith​`: Runs the base command and sub-commands in parallel, ending when the base command is finised (cf `ParallelDeadlineGroup`)
* `finallyDo`: Adds an (additional) `end` method to a command
* `raceWith`: Runs the base command and sub-commands in parallel, ending when end of them are finished (cf `ParallelRaceGroup`)
* `repeatedly`: Runs the base command repeatedly (cf `RepeatCommand`)
* `unless​`: Runs the command only if the supplied boolean is `true` (cf `ConditionalCommand`)
* `until`: Overrides the `isFinished` method.
* `withTimeout`: Adds a timer-based `isFinished` condition (cf `WaitCommand`)

(I have omitted a few of the more esoteric decorators for brevity.)

# Running commands

There are generally three ways to run a command:
* Bind it to a trigger, usually a joystick button
* Run it by default
* Run it in autonomous mode

## Triggers



## Default commands
## Autonomous commands

# Esoteric commands

These commands are used only in very specific circumstances.

* `NotifierCommand`: 
* `PIDCommand`/`ProfiledPIDCommand` 
* `RamseteCommand`
* `ScheduleCommand`
* `ProxyScheduleCommand`
* `WrapperCommand`
* `MecanumControllerCommand`
* `SwerveControllerCommand`
* `TrapezoidProfileCommand`

 # See also
 * [Binding Commands to Triggers](https://docs.wpilib.org/en/stable/docs/software/commandbased/binding-commands-to-triggers.html)
 * [Command Compositions](https://docs.wpilib.org/en/stable/docs/software/commandbased/command-compositions.html)
 * [Command interface](https://github.wpilib.org/allwpilib/docs/release/java/edu/wpi/first/wpilibj2/command/Command.html)
