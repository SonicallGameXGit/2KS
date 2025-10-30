#ifndef PROPERTIES_GLSL
#define PROPERTIES_GLSL

// #define NO_POSTPROCESSING

#define MOTION_BLUR_ENABLED
#define MOTION_BLUR_STRENGTH 0.4          // [0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0 2.25 2.5 3.0 3.5 4.0 4.5 5.0]
#define MOTION_BLUR_SAMPLES 8             // [8 16 32 64 128]
#define MOTION_BLUR_SATURATION 1.0

#define BLOOM_ENABLED
#define BLOOM_STRENGTH 1.0                // [0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 4.5 5.0]
#define BROKEN_BLOOM_ENABLED
#define BROKEN_BLOOM_STRENGTH 1.0         // [0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 4.5 5.0]
#define LENS_FLARE_ENABLED
#define LENS_FLARE_STRENGTH 1.0           // [0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]

// #define HAND_VISIBLE

#define CHROMATIC_ABBERATION_ENABLED
#define CHROMATIC_ABBERATION_STRENGTH 1.0 // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 4.5 5.0]

#define FILM_GRAIN_ENABLED
#define FILM_GRAIN_STRENGTH 0.2           // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define VIGNETTE_ENABLED
#define VIGNETTE_STRENGTH 1.0             // [0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]

#define SHARPNESS_STRENGTH 1.0            // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define DOWNSAMPLING 2                    // [0 1 2 3 4]

#define TONEMAPPING_ENABLED
#define ADJUST_RED 1.0                    // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define ADJUST_GREEN 0.85                 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define ADJUST_BLUE 0.8                   // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define DISTORTIONS_ENABLED
// #define AUTO_EXPOSURE_ENABLED
#define EXPOSURE_ADJUSTMENT 0.9           // [0.5 0.7 0.9 1.1 1.3 1.4 1.5 1.7 1.9 2.1 2.3]
#define GAMMA_CORRECTION 2.2              // [1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define BRIGHTNESS_ADJUSTMENT 0.0         // [-0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5]
#define FLICKERING_ENABLED
#define GRADIENTS_ENABLED


#define FOG_ENABLED
#define FOG_DENSITY 2.0                   // [0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FOG_DISTANCE 0.5                  // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]


#define SHADOWS_ENABLED
#define SHADOWS_QUALITY 1024              // [512 1024 2048 4096 8192]
#define SHADOWS_STRENGTH 0.8              // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]


#define GLOBAL_SHAKE_ENABLED
#define GLOBAL_SHAKE_STRENGTH 1.0         // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_FLOW_STRENGTH 1.0           // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_FLOW_SPEED 1.0              // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_MICRO_STRENGTH 1.0          // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_MICRO_SPEED 1.0             // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_DROP_STRENGTH 1.0           // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHAKE_DROP_FREQUENCY 1.0          // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define TILT_ENABLED
#define TILT_STRENGTH 1.0                 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define TILT_FLOW_STRENGTH 1.0            // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define TILT_FLOW_SPEED 1.0               // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define FISHEYE_STRENGTH 0.1              // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]
#define DISTANCE_BLUR_ENABLED


#define DATE_TIME_ENABLED
#define DATE_TIME_RED 0.8                 // [0.0 0.2 0.4 0.6 0.8 1.0]
#define DATE_TIME_GREEN 0.8               // [0.0 0.2 0.4 0.6 0.8 1.0]
#define DATE_TIME_BLUE 0.2                // [0.0 0.2 0.4 0.6 0.8 1.0]

#define BORDER_ENABLED

#endif