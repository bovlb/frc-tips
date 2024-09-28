# Coast mode

This document explains how to set neutral/idle mode so that the robot is safe in use,
but moveable when disabled.

## Background

When a motor controller is told to setting a motor's power to zero, this is known as idle mode (also known as neutral mode).  There are two different flavors of idle mode: coast mode and brake mode.

* **Coast mode** effectively disconnects the motor wires so that the motor can turn freely.  A spinning motor that is set to coast mode will slow down gradually as a result of friction.  A stationary motor in coast mode provides little resistant to movement.

* **Brake mode** effectively connects the motor wires together so that the motor provides "back EMF" that resists motion.  A spinning motor in brake mode will slow down very quickly when the power is set to zero.  A stationary motor in brake mode will be hard to turn.

So which do we want to use on an FRC robot?  The answer, in most cases, is brake mode.  A drive train in brake mode will stop quickly when commanded (say before hitting an obstacle).  This reduces wear and tear on your practice space and any unobservant humans present.  A motor-actuated elevator or climber will, in brake mode, lock and resist descent, meaning you may be able to get away without adding brakes.  A drive train stopped on a ramp will stay there even after being disabled.  Remember that end game points are often assessed some number of seconds after the end of the match.

The main circumstance where you want your robot to be in coast mode is when you are positioning your robot by hand (while it is turned on, but disabled).  It's very hard to move an FRC robot in brake mode.  When you're perfecting your autonomous routines, you're going to be spending a lot of time repositioning your robot.

In this case, it is tempting to say that the robot's drive train should be in brake mode while enabled, but go into coast mode when disabled.  You might get away with this, but one day you'll disable your robot when it is going at high speed, and then everyone will be unpleasantly surprised that it just keeps on going.  This has actually happened in some FRC competition matches, where a robot in motion at the end of the match keeps moving, collides with other robots, and either loses end game points for their alliance or gains fouls as a result.

So what should we do?  The best compromise seems to be to enable coast mode only once the robot has been disabled for several seconds, and keep it in brake mode at all other times.  That gives it enough time to stop, allows enough time for post-match judging, but still makes it easy to move your robot.  Fortunately, with appropriate configuration, idle mode commands can be sent to your motors while the robot is disabled.

## Method

So how do we do this?  You need to do three things:
* Create a method in your drive subsystem that can set the idle mode to either coast or brake
* Set brake mode in appropriate places
* Set coast after several seconds of being disabled

### Drive sybsystem

The exact command required will vary depending on your drivetrain and the motor controllers.  Here I give code for Spark Max and Talon FX, assuming two motors on each side.

#### SparkMAX

```java
/**
 * Sets idle mode to be either brake mode or coast mode.
 *
 * @param brake If true, sets brake mode, otherwise sets coast mode
 */
public Command setBrakeMode(boolean brake) {
    IdleMode mode = brake ? IdleMode.kBrake : IdleMode.kCoast;
    return Commands.runOnce(() -> { // Instant command will execute our "initialize" method and finish immediately
        m_leftLeader.setIdleMode(mode);
        m_leftFollower.setIdleMode(mode);
        m_rightLeader.setIdleMode(mode);
        m_rightFollower.setIdleMode(mode);
    }).ignoringDisable(true); // This command can run when the robot is disabled
}
```
#### Talon FX/SRX (including Falcon 500)
```java
public Command setBrakeMode(boolean brake) {
    NeutralMode mode = brake ? NeutralMode.Brake : NeutralMode.Coast;
    return Commands.runOnce(() -> {
        m_leftLeader.setNeutralMode(mode);
        m_leftFollower.setNeutralMode(mode);
        m_rightLeader.setNeutralMode(mode);
        m_rightFollower.setNeutralMode(mode);
    }).ignoringDisable(true);
}
```

### Set brake mode on init

In `Robot.java`, in both `autonomousInit` and `teleopInit`, add the following line:
```java
m_robotContainer.m_driveSubsystem.setBrakeMode(true).schedule(); // Enable brake mode
```

You may need to change this code, depending on where your drive subsystem is created and stored.  You may also need to change `RobotContainer.m_driveSubsystem` to be `public`.

### Create trigger

In `Robot.java`, at the end of `robotInit`, add the following code:

```java
// Turn brake mode off shortly after the robot is disabled

new Trigger(this::isEnabled) // Create a trigger that is active when the robot is enabled
        .negate() // Negate the trigger, so it is active when the robot is disabled
        .debounce(3) // Delay action until robot has been disabled for a certain time
        .onTrue( // Finally take action
                m_robotContainer.m_driveSubsystem.setBrakeMode(false)); // Enable coast mode in drive train
```

Notes:
* The `Trigger` can be constructed with a `BooleanSupplier`.  Here `Robot` has a method `isEnabled` which takes no arguments and returns a `boolean`.  Such methods can be treated as a `BooleanSupplier`.  The syntax is a little tricky here because we're trying to pass in a class method in the context of this particular instance of `Robot`.  We do this using the `this` implicit method variable and the (seldom-used) `::` method reference operator.
* We want to do something when the robot is disabled, but there is no `isDisabled` method, so we have to use `isEnabled` and negate it.  This means the trigger will activate whenever the `isEnabled` method returns `false`.  Notice that methods like `negate` return a new `Trigger`, so they can be chained in a terse style.
* We don't want to activate this trigger immediately the robot is disabled, but several seconds afterwards.  The `debounce` creates a new trigger that does not activate until its input trigger has been consistently active for some number of seconds.  (If this is new to you, think about using [Debouncer](https://first.wpi.edu/wpilib/allwpilib/docs/release/java/edu/wpi/first/math/filter/Debouncer.html#%3Cinit%3E(double)) the next time you have trouble with noisy beam break sensors.)
Choose your own time here.  It needs to be long enough that the robot will come to a stop, but not so long that you're standing around waiting for it.  It's also a good idea to look at the rulebook and see if the robot has to stay in position on a ramp for some number of seconds.
* Change the call to `setBrakeMode` as neccessary, depending on where your drive subsystem can be found.

## References
* [Oblarg's comment on Chief Delphi that started me on this path](https://www.chiefdelphi.com/t/making-carrying-loading-robots-onto-and-off-the-field-safer/413630/51?u=bovlb)
* [WPILIB Convenience Features](https://docs.wpilib.org/en/stable/docs/software/commandbased/convenience-features.html)
* [WPILIB Binding Commands to Triggers](https://docs.wpilib.org/en/stable/docs/software/commandbased/binding-commands-to-triggers.html)
* [CANSparkMax Java doc](https://codedocs.revrobotics.com/java/com/revrobotics/cansparkmax)
* [TalonFX Java doc](https://store.ctr-electronics.com/content/api/java/html/classcom_1_1ctre_1_1phoenix_1_1motorcontrol_1_1can_1_1_talon_f_x.html)
* [Trigger Java doc](https://first.wpi.edu/wpilib/allwpilib/docs/release/java/edu/wpi/first/wpilibj2/command/button/Trigger.html)
* [Java 8 – Double Colon (::) Operator](https://javabydeveloper.com/java-8-double-colon-operator/)
