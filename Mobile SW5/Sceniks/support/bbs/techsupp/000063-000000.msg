wayne
glasser
sales@mwignitions.com
11/25/98 1:39 AM
Problem with port B interrupt
options:email:sales@mwignitions.com

We are experiencing a problem when using the port B interrupt on an 18 pin 9818 date device.  If another interrupt is received before the first code has cleared and returned, the interrupt system becomes inoperative however non interrupt code keeps running.  Is this a known bug or is there something we need to do within or when exiting the interrupt code to stop this happening.  I have included a sample of the source code we were using to track the problem
