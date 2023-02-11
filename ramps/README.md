https://bovlb.github.io/frc-tips/ramps/

# Ramps

This document describes ways to stop your robot from falling over in teleoperated driving.

An ideal FRC robot would have a centre of mass that is near the ground, and centred in the frame perimeter.  In practice, the various game requirements make this hard to achieve, and you often end up with a top-heavy robot with all the weight at one end.  The means that if you accelerate or decelerate too aggressively in the wrong direction, your robot could fall over.  Even if the robot doesn't actually fall over, just picking the wheels up could be enough to allow another robot or a game piece to slide underneath.

As with many aspects of robot programming, the answer lies in not always doing what the driver asks for.  When the driver slams the stick from full forwards to full reverse, we make the robot response lag very slightly.  Ramping is usually measured in terms of the minimum time the robot will take to go between neutral and full power.  Good values for this will range between about 0.1s and 0.5s depending on how top-heavy your robot is, and how much lag the driver will tolerate.  I recommend that you set the ramp time as high as your driver will permit (but no higher).

You might add the following to `Constants`:
```java
final static k_rampTimeSeconds = 0.25;
```

Remping is generally used for the drive train, although it can sometimes apply to other subsystems.  It is also generally used only for telemetric operation; it can also apply to autonomous routines, but that is better handled by setting maximum acceleration in path planning.

There are a number of different ways to implement ramps.  [ TODO: Add more than one. ]

## Slew Rate Limiter

The easiest and simplest way to add ramps is using a class called `SlewRateLimiter`.  This can be applied directly to your control inputs (e.g. your joystick) inside your arcade drive command.

You probably have an arcarde drive command where the `execute` method looks something like:

```java
// Existing ArcardeDrive code
double forward = ...; // Probably from -Y on the joystick
double turn = ...; // Probably from X on the joystick

// Do something with forward and turn
// Probably looks like ONE of the following:
m_driveSubsystem.setPower(forward + turn, forward - turn);
m_driveSubsystem.setSpeed((forward + turn) * k_maxSpeed, (forward - turn) * k_maxSpeed);
m_driveSubsystem.arcadeDrive(forward, turn);
m_driveSubsystem.getDrivetrain().arcadeDrive(forward, turn, true);
```

To add ramping, add a new member variable in the `ArcadeDrive` command:
```java
// If the driver moves the joystick too fast, add a little lag
SlewRateLimiter m_filter = new SlewRateLimiter(1.0 / Constants.k_rampTimeSecond);
```

Note that SlewRateLimiter does not take a time; instead it takes a rate (units of change per second).  I have found that it's much easier to talk to the drivers about lag time, which is is why I use that as the defined constant.  Some other ramping techniques take a time directly instead of a rate.

In `ArcadeDrive.execute`, simply replace `forward` with `m_filter.calculate(forward)`, for example:
```java
// Apply ramping filter to forward control
forward = m_filter.calculate(forward);
```

Note that we're only applying the ramp to the forwards/backwards axis and not the turn.  
Rapid turns alone are not usually enough to tip the robot.  If you find that the robot turns too rapidly, remember that it's common practice to limit the maximum permissible rate of turn.  This can be done simply by multiplying the turn value from the joystick by a constant like `0.5`.

If you do decide to apply ramping to the turn control, you will need to create a second `SlewRateLimiter`; 
the filter has internal state, so don't try to use one filter for two data streams.

## References

* [Slew Rate Limiter](https://docs.wpilib.org/en/stable/docs/software/advanced-controls/filters/slew-rate-limiter.html)