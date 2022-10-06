# Ramps

An idea FRC robot would have a centre of mass that is near the ground, and centred in the frame perimeter.  In practice, the various game requirements make this hard to achieve, and you often end up with a top-heavy robot with all the weight at one end.  The means that if you accelerate or decelerate too aggressively in the wrong direction, your robot could fall over.  Even if the robot doesn't actually fall over, just picking the wheels up could allow another robot to slide underneath.

As with many aspects of robot programming, the answer lies in not always doing what the driver asks for.  When the driver slams the stick from full forwards to full reverse, we make the robot response lag very slightly.  Ramping is usually measured in terms of the minimum time the robot will take to go between neutral and full power.  Good values for this will range between about 0.1s and 0.5s depending on how top-heavy your robot is, and how much lag the driver will tolerate.  I recommend that you set the ramp time as high as your driver will permit (but no higher).

```java
final static k_rampTimeSeconds = 0.25;
```

Ramping is generally something we think about in the context of telemetric operation, especially for the drive train.  It can apply to other subsystems.  It can also apply to autonomous routines, but it has to be applied with some care.

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
m_driveSubsystem.setPower(y+x, y-x);
m_driveSubsystem.setSPeed((y+x)*k_maxSpeed, (y-x)*k_maxSpeed);
m_driveSubsystem.arcadeDrive(forward, turn);
m_driveSubsystem.getDrivetrain.arcadeDrive(forward, turn, true);
```

  SlewRateLimiter m_filter = new SlewRateLimiter(4);

## References

* [Slew Rate Limiter](https://docs.wpilib.org/en/stable/docs/software/advanced-controls/filters/slew-rate-limiter.html)