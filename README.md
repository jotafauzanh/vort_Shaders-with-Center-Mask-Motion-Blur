# vort Shader with Center Mask Motion Blur

**DISCLAIMER**: Most of my changes is made using github copilot, because i have major disease called skill issue

original vort_Shaders github repo: [https://github.com/vortigern11/vort_Shaders](https://github.com/vortigern11/vort_Shaders)

# Description

| Halo Reach | Halo Reach visualization |
|---|---|
| ![halo_reach_mb_mask](https://github.com/user-attachments/assets/21657bca-6cf4-4b4c-a7ef-8468e4e3c85d) | ![halo_reach_mb_mask_opacity](https://github.com/user-attachments/assets/25772634-995e-4fc7-9138-c0939514e6e3) |

This fork of vort_Shader adds Center Mask Motion Blur. This implements motion blur similar to Bungie's motion blur implementation in Halo 3, Halo 3: ODST, Halo Reach, Destiny 1, Destiny 2, and Marathon. The difference from other motion blur implementations, is that the center of the screen is excluded from the processing of the motion blur itself, then the intensity of the motion blur rolls off to another point, then the edges of the screen receives full motion blur.

This implementation of motion blur is better suited for videogames, especially shooters/first person games. Shooter games benefit from image clarity, so that they can identify the enemies better. A normal fullscreen blur will also blur what you're aiming at, which is detrimental when you and/or the enemy is moving. By omitting the middle of the screen from motion blur, players can track their enemies better while still getting the perceptual smoothness boost from edge motion blur. This is a good compromise to get the best out of both worlds.

| vort_Shaders with CMMB | with visualization |
|---|---|
| ![my_shader](https://github.com/user-attachments/assets/a1e37755-04c9-40d0-83ec-8d763ccbf6f5)| ![my_shader_vis](https://github.com/user-attachments/assets/7791c877-d7ca-4d86-8720-adf43f1a67e9) |

vort_Shaders did the heavy lifting of figuring out how to implement motion blur via reShade. This repository adds additional check to mask the middle portion.
There are 3 variables:
- Inner Circle which anything in the middle of the circle stays sharp. 
- Outer Circle which anything inbetween inner and outer has a motion blur rolloff, and anything outside outer has full motion blur
- Vertical which because some games like Halo has their crosshair not centered, so this allows the user to move the motion blur.

There's also circle visualization to help finetune settings. Default settings mimicks Halo Reach's setting, which I feel is a good balance. Currently it's only implemented on vort_Shaders' High Quality Motion Blur setting. As with vort_Shaders recommendation, higher fps will look much better, but you can fine tune the samples settings to make it look better on lower fps. In my opinion, 75 fps and above looks good.

# Video Showcase:
[![youtube video showcase](https://img.youtube.com/vi/xWWfboPWnkI/0.jpg)](https://www.youtube.com/watch?v=xWWfboPWnkI)

https://github.com/user-attachments/assets/39e52739-7f86-4251-85ff-876752a3f0f1

The video is ~120fps gameplay captured in 60fps, so the motion blur quality looks a bit worse than how it should.

# How to use
1. Read the original repo first: [https://github.com/vortigern11/vort_Shaders](https://github.com/vortigern11/vort_Shaders)
2. Install reshade with addon for the game
3. Download this repository. You can get it from releases: [releases](https://github.com/jotafauzanh/vort_Shaders-with-Center-Mask-Motion-Blur/releases/)
4. Put the contents inside zip from releases to `reshade-shaders`
5. Start game, enable vort_Motion on Reshade menu
6. put `2` on motion_blur
7. You can tweak the settings from a new dropdown called motion blur

# Troubleshooting
While most of the problems is unrelated to my changes, I will put it here anyways

### 1. My UI is warped by the motion blur
Read the original repo to learn how to use REST: [https://github.com/vortigern11/vort_Shaders](https://github.com/vortigern11/vort_Shaders)

### 2. Motion blur direction is random
Make sure the depth information is correct. To troubleshoot check this out: [marty's depth troubleshoot](https://guides.martysmods.com/reshade/depth/)
