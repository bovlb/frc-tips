https://github.com/bovlb/frc-tips/tree/main/can-bus

# CAN bus

## What is your CAN bus utilization?

The Driver Station and the DS Logs will show you your CAN bus utilization rate.  Often this is a fuzzy line that ranges up to 100%.  This doesn't necessarily mean that your CAN bus utilization is actually that high.  The real value can be seen by zooming in (in the DS Log Viewer) to find the common, stable value.  Typically it will be near the bottom of the fuzzy band.

How much is too high?  70% is fine.  If you're going much higher than that, you're likely to be experiencing lost packets and various errors. If not, you should look elsewhere for your problem.

There are four main ways to fix a high CAN utilization.  At a competition, they should probably be tried in this order.
* Check your wiring and termination.  Noisy CAN bus wiring or a missing terminator will reduce available bandwidth.
* Adjust the frame rates on your motors.
* Switch motors to PWM.  This may be appropriate for, say, intake motors, when the precise speed is not important.
* Install additional hardware like the CANivore.

## Check your wiring

https://docs.wpilib.org/en/stable/docs/hardware/hardware-basics/can-wiring-basics.html

* Do the wiggle check
* Check for bare metal or whiskers
* Check termination
* Check cables are twisted
* Use [Phoenix Tuner](https://store.ctr-electronics.com/software/) and [Rev Hardware Client](https://docs.revrobotics.com/rev-hardware-client/) to check device visibility

## Adjusting frame rates

If you are having problems with high CAN bus utilization, consider turning down the frame rate.  These are not general recommendations!  Don't do it if you're not having trouble!

Motor controllers will typically have multiple types of status frame that can be controlled separately.  Status frames have multiple uses:
* Motor safety watchdog: The roboRIO will shutdown any motor it has not heard from in 100ms.
* Following: The follower listens for certain information from the leader.
* Software PID: If you are using software PID, then you need to know motor velocity or position every 20ms.
* Odometry: If you are using dead reckoning, you need to know motor positions every 20ms.

The motor safety watchdog is an important case.  It is recommended that you do not set such frames over 45ms.  This means that you can drop the occasional frame without triggering it.

If a motor is under power/voltage control, or is using firmware PID control with no follower, then status frames can be less frequent.  

### REV Spark MAX 

The Spark MAX has five different types of periodic status frame, but I believe a typical FRC setup will only use the first three.  
* Type 0 is "Applied ... Output" and faults.  Default 10ms.  I believe this is the one used for the watchdog, so it should not be more than 45ms.  I could be wrong, but I think is also what the follower relies on from the leader.
* Type 1 is velocity, temperature, voltage, and current.  Default 20ms.
* Type 2 is position.  Default 20ms.

E.g.
```java
// Maximum reasonable values
leader.setPeriodicFrameRate(PeriodicFrame.kStatus0, 20); 
leader.setPeriodicFrameRate(PeriodicFrame.kStatus1, 50); 
leader.setPeriodicFrameRate(PeriodicFrame.kStatus2, 50); 
follower.setPeriodicFrameRate(PeriodicFrame.kStatus0, 45); 
follower.setPeriodicFrameRate(PeriodicFrame.kStatus1, 500); 
follower.setPeriodicFrameRate(PeriodicFrame.kStatus2, 500);
```

### CTRE Phoenix (e.g. Talon/Falcon, Pigeon, CANcoder)

#### Motor controllers (Talon/Falcon)

Ten different types, but two important ones:
* Type 1: Applied Motor Output, Fault Information, Limit Switch Information.  Default 10ms.
* Type 2: Selected Sensor Position, Selected Sensor Velocity, Brushed Supply Current Measurement, Sticky Fault Information.  Default 10ms.

```java
// Maximum reasonable values
leader.setStatusFramePeriod(StatusFrameEnhanced.Status_1_General, 20);
leader.setStatusFramePeriod(StatusFrameEnhanced.Status_2_Feedback0, 50);
follower.setStatusFramePeriod(StatusFrameEnhanced.Status_1_General, 45);
follower.setStatusFramePeriod(StatusFrameEnhanced.Status_2_Feedback0, 500);
```

## Switch motors to PWM

[WPILIB How to wire PWM cables](https://docs.wpilib.org/en/stable/docs/zero-to-robot/step-1/how-to-wire-a-robot.html?highlight=PWM#pwm-cables)

```java
  private final PWMSparkMax m_leftDrive = new PWMSparkMax(0);
  private final PWMSparkMax m_rightDrive = new PWMSparkMax(1);
```

Pass to `DifferentialDrive` or call `.set()`.

Similarly for `PWMTalonFX` (Falcon 500) and `PWMTalonSRX`.

[WPILIB Using PWN Motor Controllers](https://docs.wpilib.org/en/stable/docs/software/hardware-apis/motors/using-motor-controllers.html#using-pwm-motor-controllers)

## Additional hardware
### CANivore

Might help.  Introduces its own complexity.  Doesn't work with sysid.

[CTRE Canivore Hardware Manual](https://store.ctr-electronics.com/content/user-manual/CANivore%20User's%20Guide.pdf)

[CTRE Bring Up: CANivore](https://docs.ctre-phoenix.com/en/stable/ch08a_BringUpCANivore.html)

```java
    TalonFX motor = new TalonFX(deviceNumber, canivoreName);
```

## References and further reading
* [Rev Spark MAX periodic sttus frames](https://docs.revrobotics.com/sparkmax/operating-modes/control-interfaces#periodic-status-frames)
* [CTRE Setting status frame periods](https://docs.ctre-phoenix.com/en/stable/ch18_CommonAPI.html#setting-status-frame-periods)
* [WPILIB Driver Station log viewer](https://docs.wpilib.org/en/stable/docs/software/driverstation/driver-station-log-viewer.html)
* [`BaseTalon.setStatusFramePeriod`](https://api.ctr-electronics.com/phoenix/release/java/com/ctre/phoenix/motorcontrol/can/BaseTalon.html#setStatusFramePeriod(com.ctre.phoenix.motorcontrol.StatusFrameEnhanced,int,int))
* [CD comment: three types of interaction with a CAN device](https://www.chiefdelphi.com/t/can-bus-freezes-on-code-initialization/419481/13?u=bovlb)