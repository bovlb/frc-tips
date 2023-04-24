https://bovlb.github.io/frc-tips/burnout/

# Burnout

We put motors on our robots because we want to transform electricity into motion.  Unfortunately, because of internal inefficiencies and forces/torques that resist motion, much of that electrical energy is instead transformed into heat (and some noise).  If a motor becomes too hot, it will fail, usually by burning off the thin enamel coating on the winding wires.  This is often referred to as "letting out the magic smoke".

If a motor is pushing against more force/torque than it is generating, then all of the input energy is transformed into heat.  This is called "stalling".  Many motors are "self cooling", which means that as they turn, air is drawn through the motor to dissipate the heat.  Unfortunately, motors are not good at getting rid of heat when stationary, so stalling is the most common way to burn out motors.  Don't make the mistake of thinking that a stationary motor is not drawing any power.

Some motors (e.g. CTRE/VEX Falcon 500) have "thermal protection", which means that they monitor their own internal temperature and simply stop working until they have cooled down a bit.  This is good for protecting your investment, but bad if it happens in the middle of a match.  It's much better not to reach that point.

Here are some common scenarios when a motor might stall and therefore be at risk of burning out:
* A game piece (e.g. a squashy ball) is jammed in the serializer
* A robot experiences aggressive defence and is unable to move
* A limit switch fails on an intake or turret
    * Consider making limit switches "normally closed" (NC) so the more common failure mode (disconnection) is detected quickly.
* A servo motor is mechanically misaligned and cannot reach its set position
* An intake or elevator requires continuous power to stay in position
    * Consider using brake mode on the motors, adding a physical brake, or changing the mechanical design to reduce the torque
* The drive train receives contiunuous small signals that don't result in (much) movement
    * While this is usually too small to cause burnout in the typical timescale of an FRC match, it's a good idea to use [deadband](https://github.wpilib.org/allwpilib/docs/release/java/edu/wpi/first/math/MathUtil.html#applyDeadband(double,double)) on joystick inputs

While in many cases there are other possible solutions, there are some simple things we can do in software to limit this risk.  Primarily we can limit the current on motors.  If you look at the manufacturer websites, you can often find charts showing how long a motor will sustain a specific current before failing.  For example, the Falcon 500 will hit thermal protection after about 110 seconds at 50A, and 260 seconds at 40A.  

Don't assume that because a motor is on a 40A circuit, its current will never exceed 40A.  It often makes sense to use a current limit that is greater than the rating of the fuse/circuitbreaker installed on the circuit.


## Choosing a current limit

Before applying current limiting, you should get an idea of what your typical current draw is so that your limits don't affect normal usage.  You can monitor current draw by motors in several ways:
* Looking at the PDP/PDH in SmartDashboard/Shuffleboard.  
    * `SmartDashboard.putData(new PowerDistribution());`
* Looking at your [Driver Station logs](https://docs.wpilib.org/en/stable/docs/software/driverstation/driver-station-log-viewer.html)


In both cases, the first thing you will realise is that you need to know which motor is connected to which circuit.  Of course, all the wires on your PDB/PDH are already clearly labelled, but [a cool trick](https://www.chiefdelphi.com/t/favorite-tools-materials-and-techniques-for-frc-wiring/353212/72?u=bovlb) is to use the same CAN bus id as the circuit number.  If you do this, it means all of your circuit numbers are already documented in `Constants.java`. 

For a drive train, a [useful technique](https://www.chiefdelphi.com/t/how-to-prevent-swerve-drive-motor-burnout/423820/7?u=bovlb) is put the robot on a carpet, touching a wall and then gradually increase the power until the wheels start to slip.  Set the current limit to the peak current at the moment when the wheels start to slip.

I haven't tried it myself, but the [ILITE Drive Train Simulator](https://github.com/flybotix/drivetrainsim) is supposed to give some useful information about currents.

> **Warning**
> The specific current values in the example code below are only for illustration.
> You should pick your own values.

## Current limiting

How you limit the current depends on what sort of motor contoller you're dealing with.  When you set a limit, the controller will reduce the control inputs to keep the current at that level.  

As always, this sort of intervention makes the robot not do what the driver asks for, so should be applied with caution.  If drivers find that current limiting makes it harder to drive the robot then relax (increase) the limits rather than just removing them.

### TalonSRX 

These controllers allow you to set supply, peak, and continuous current limits.  The supply limit is primarly used to prevent breakers from tripping.  The peak limit is engaged whenever the current tries to exceed that level.  The continuous limit is engaged if the current tries to exceed that level for more than a certain time.  See the [documentation](https://store.ctr-electronics.com/content/api/java/html/classcom_1_1ctre_1_1phoenix_1_1motorcontrol_1_1can_1_1_talon_s_r_x.html) for more details.

```java
// Use this to stop breakers from tripping
m_motor.configSupplyCurrentLimit(40); // Amperes
// Use these to prevent burnout 
m_motor.configPeakCurrentLimit(35); // Amperes
m_motor.configPeakCurrentDuration(200); // Milliseconds
m_motor.configContinuousCurrentLimit(25); // Amperes
m_motor.enableCurrentLimit(true);
```

### TalonFX (including Falcon 500)

These controllers allow you to limit supply and stator current.  The supply current is what is going to pop the breaker.  The stator current is what is going through the windings and will cause burnout.  These have two current levels: a higher "threshold" level that activates the limit, and a lower level that the current is limited to when active.  See the [documentation](https://store.ctr-electronics.com/content/api/java/html/classcom_1_1ctre_1_1phoenix_1_1motorcontrol_1_1can_1_1_talon_f_x.html#a68a40924fbcf1d8f31c04631a25e437c) for more details.

```java
// Use this to stop breakers from tripping
m_motor.configSupplyCurrentLimit(
    new SupplyCurrentLimitConfiguration(
        true, // enable
        35, // current limit in Amperes
        40, // threshold current for activation in Amperes
        0.2 // time exceeding threshold for activation in seconds
    )
);

// Use this to prevent burnout
m_motor.configStatorCurrentLimit(
    new StatorCurrentLimitConfiguration(
        true, // enable
        35, // current limit in Amperes
        40, // threshold current for activation in Amperes
        0.2 // time exceeding threshold for activation in seconds
    )
);
```

### CAN SparkMAX

This controller allows you to limit current as a function of the speed of the motor.  The actual limit applied is a linear interpolation between the two values.  This means that you can handle the stalling case without limiting the non-stalling current.  See [the documentation](https://codedocs.revrobotics.com/java/com/revrobotics/cansparkmax#setSmartCurrentLimit(int)) for variants on this method that allow slightly different control models.

```java
m_motor.setSmartCurrentLimit(
    10, // stall limit in Amperes
    100 // free speed limit in Amperes
);
```

`CANSparkMax` also provides `setSecondaryCurrentLimit` which works somewhat differently, but you probably don't want to touch that for an FRC robot.

### Victor SPX

The Victor SPX does not provide any current limiting feature.

TODO: Add code snippet on how to limit current based on PDB/PDH reporting.

## Temperature Control

Another possible approach is temperature control.  Some motor controllers will report the temperature of the motor and you can temporarily stop using a motor when it is too hot.  This technique is not widely applicable in the FRC context, but you might use it, say, if it takes continuous power to hold an intake up and the consequences of letting the intake droop are fairly minor.

### CAN SparkMAX

```java
boolean m_stopped;

@Override
public void initialize() {
    // ...
    m_stopped = false;
}

@Override
public void periodic() {
    double motorTemperature = m_motor.getMotorTemperature()
    if(m_stopped) {
        if(motorTemperature <= 48) {
            m_stopped = false;
        }
    } else if(motorTemperature > 50) {
        m_stopped = true;
    }

    if(m_stopped) {
        m_motor.set(0)
    } else {
        // do stuff
    }
}
```

### TalonSRX and TalonFX (including Falcon 500)

The Talon motor controller also has a `getTemperature()` method, but the documention says that it returns the temperature of the controller, not the motor.  This might be useful with integrated controllers like the Falcon 500, but I have not tested it.