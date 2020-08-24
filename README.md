# Dependencies

- Software: ARMSim 2.01
- Plugin: SWI Legacy

# Official documentation
- [VFP instructions - Float32 for ARM Assembly](https://developer.arm.com/documentation/dui0489/c/neon-and-vfp-programming/vfp-instructions)  
- [ARMSim# User Guide (SWI reference)](https://www.lri.fr/~de/ARM-Tutorial.pdf)

# Description
## Function
## Theory

To obtain the cos(x) result the program makes use of the Taylor Series expansion for cosine function.  
![](/misc/Taylor.png)
In the graph, x represent the angle in **radians**.  

The program gives precise results for the angles from 0 to 180 degrees. It's posible to calculate cosine for the angles greater than 180 by adding more expansion terms to the TAYLOR_SERIES function.

## I/O

The input is obtained from the archive input.txt that should be created and moved to the same directory as the main program before executing it.  
input.txt is a plain archive which should contain one line with the value of an angle to use. Note: the input angle should be presented in degrees - the program will handle degrees-to-radians convertion.  

Example of the input archive: [input.txt](input/)

