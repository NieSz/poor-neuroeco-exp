This repo provides code for interfacing with SMI eye trackers. For further
documentation of the CBU eye tracking setup, see the [CBU imaging
wiki](http://imaging.mrc-cbu.cam.ac.uk/meg/EyeTracking).

# Matlab (serial port communication)
For a high-level calibration script, see
[fullCalibrationRoutine.m](fullCalibrationRoutine.m).

For a minimal example, see [eyetrackdemo.m](eyetrackdemo.m).

For complete documentation, see [this wiki
entry](http://imaging.mrc-cbu.cam.ac.uk/meg/EyeTrackingWithMatlab).

# Matlab (ethernet communication)
Please note that the code above is somewhat outdated - the release of the [SMI
Matlab
SDK](https://uk.mathworks.com/products/connections/product_detail/product_119541.html)
makes it possible to interface with the eye tracker using ethernet, which is
faster and much easier. If you need advanced eye tracking applications (e.g.,
gaze-contingent displays), this will be a better approach. If you just want to
calibrate, log trials and check fixation accuracy, the above serial-port code is
probably good enough. 

# E-Prime
We use SMI's SDK. See [this wiki entry](http://imaging.mrc-cbu.cam.ac.uk/meg/EyeTrackingWithEprime).

# Others
Presentation should also work - again there is an SMI SDK.
