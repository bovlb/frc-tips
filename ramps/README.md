# Ramps

This document describes ways to stop your robot from falling over in teleoperated driving.

> ⚠️ **Warning**
> This is a work in progress and has not had extensive testing.


An ideal FRC robot would have a centre of mass that is near the ground, and centred in the frame perimeter.  In practice, the various game requirements make this hard to achieve, and you often end up with a top-heavy robot with all the weight at one end.  The means that if you accelerate or decelerate too aggressively in the wrong direction, your robot could fall over.  Even if the robot doesn't actually fall over, just picking the wheels up could allow another robot to slide underneath.

As with many aspects of robot programming, the answer lies in not always doing what the driver asks for.  When the driver slams the stick from full forwards to full reverse, we make the robot response lag very slightly.  Ramping is usually measured in terms of the minimum time the robot will take to go between neutral and full power.  Good values for this will range between about 0.1s and 0.5s depending on how top-heavy your robot is, and how much lag the driver will tolerate.  I recommend that you set the ramp time as high as your driver will permit (but no higher).

You might add the following to `Constants`:
```java
final static k_rampTimeSeconds = 0.25;
```

Ramping is generally something we think about in the context of telemetric operation, especially for the drive train.  It can apply to other subsystems.  It can also apply to autonomous routines, but that has to be done with great care.

There are a number of different ways to implement ramps.  TODO

## Slew Rate Limited

The easiest and simplest way to add ramps is using a class called `SlewRateLimiter`.  This can be applied directly to your control inputs (e.g. your joystick) inside your arcade drive command.

You probably have an arcarde drive command where the `execute` method 

looks something like:

```java
double forward = ...; // Probably from -Y on the joystick
double turn = ...; // Probably from X on the joystick

// Do something with forward and turn
// Probably ONE of the following:
m_driveSubsystem.setPower(forward + turn, forward - turn);
m_driveSubsystem.setSpeed((forward + turn) * k_maxSpeed, 
    (forward - turn) * k_maxSpeed);
m_driveSubsystem.arcadeDrive(forward, turn);
m_driveSubsystem.getDrivetrain().arcadeDrive(forward, turn, true);
```

To add ramping, add a new member variable in the `ArcadeDrive` command:
```java
  SlewRateLimiter m_filter = new SlewRateLimiter(1.0 / Constants.k_rampTimeSecond);
```

And in `execute`, change `forward` to be `m_filter.calculate(forward)`, e.g.:
```java
m_subsystem.getDrivetrain().arcadeDrive(m_filter.calculate(forward), x, true);
```

Note that we're only applying the ramp to the forwards/backwards axis.  
Rapid turns alone are not usually enough to tip the robot.
If you do decide to apply ramping to the turn control, remember to create a second `SlewRateLimiter`; 
don't try to use the same stateful filter for two data streams.

## References

* [Slew Rate Limiter](https://docs.wpilib.org/en/stable/docs/software/advanced-controls/filters/slew-rate-limiter.html)