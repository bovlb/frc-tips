# Lambda Functions

Normally, when you write a function in Java, you do in the context of some class.  Such functions are called "methods" and must be called either on an instance object or (more rarely) on the class itself.

It is sometimes useful to have a function that can be called without an object or class.  This is typically because you need to pass the function (reference) as an argument to some method to be invoked later.  With WPILIB, these are commonly used with triggers and commands.

The most common way to create such anonymous functions is using a lambda expression.  This takes an argument list and a value expression, separated by a `->` arrow.  (Compare with the `lambda` keyword in languages like Python.)

```java
// Lambda expression for a function that takes three arguments and calculates their sum
(x,y,z) -> x + y + z
```

Just like in a normal method, the value expression is not evaluated until it the function is actually invoked.

It is also possible to turn any method into a function using the `::` method reference operator.

```java
class MySubsystem ... {
    ...
    boolean getLimitSwitch() { ... }
}

// Get an anonoymous function reference with the same arguments and return type.
// Use this as a boolean supplier without having to know about the subsystem.
subsystem::getLimitSwitch
```

There are some specific types of anonymous function that have special uses: suppliers, consumers, runnables, and callables.  These are actually all classes, but the clever part is that Java will automatically convert anonymous functions into instances of those classes if you use them in the right context.  Suppliers and runnables are often encountered with WPILIB, whereas consumers and callables are not.

## Suppliers

A supplier is a class that supplies values of some specific type when you call the appropriate `getAsX` method.  It can be created from an anonymous function that takes no argument and returns a value of that type.

```java
() -> subsystem.getLimitSwitch() // BooleanSupplier
() -> joystick.getX() // DoubleSupplier
() -> joystick.getX() > 0.0 // BooleanSupplier
```

These suppliers can then be used later to fetch the value:
```java
class ArcadeDrive extends Command {
    DoubleSupplier m_speed;
    DoubleSupplier m_turn;
    DriveSubsystem m_subsystem;

    ArcadeDrive(DriveSubsystem subsystem, DoubleSupplier speed, DoubleSupplier turn) {
        m_speed = speed;
        m_turn = turn;
        m_subsystem = subsystem;
    }

    @Override
    void execute() {
        double drive = m_drive.getAsDouble();
        double turn = m_drive.getAsDouble();
        m_subsystem.drive(drive+turn, drive-turn);
    }
}
```

Suppliers are a good way to isolate dependencies.  In the code above, `speed` and `turn` probably come from a joystick, but this code doesn't need to know anything about joysticks.  This means that you can change to a different type of joystick or even bring in semi-autonomous "driver assist".

## Runnables

A `Runnable` is a class that has a `void run()` method.  It can be created from an anonymous function that takes no arguments (and any return value is ignored).  In WPILIB, it can be used to create commands on-the-fly using `InstantCommand`, `RunCommand`, `StartEndCommand`, or `FunctionalCommand`.  It can also be passed to many trigger methods (along with a required subsystem).