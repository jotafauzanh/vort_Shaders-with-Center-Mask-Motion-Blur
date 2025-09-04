# vort Shader with Center Mask Motion Blur

DISCLAIMER: Most of my changes is made using AI, because I don't know how to code graphics

original github repo: https://github.com/vortigern11/vort_Shaders

| Halo Reach | Halo Reach visualization |
|---|---|
| ![halo_reach_mb_mask](https://github.com/user-attachments/assets/21657bca-6cf4-4b4c-a7ef-8468e4e3c85d) | ![halo_reach_mb_mask_opacity](https://github.com/user-attachments/assets/25772634-995e-4fc7-9138-c0939514e6e3) |

This fork of vort_Shader adds Center Mask Motion Blur. This implements motion blur similar to Bungie's motion blur implementation in Halo 3, Halo 3: ODST, Halo Reach, Destiny 1, Destiny 2, and Marathon. This is made because it's a good compromise of getting a sharp image in the middle of battle, and Halo MCC on PC doesn't implement bungie's motion blur (although it has some blurring on movement).

| Modified vort_Shader | with visualization |
|---|---|
| ![my_shader](https://github.com/user-attachments/assets/a1e37755-04c9-40d0-83ec-8d763ccbf6f5)| ![my_shader_vis](https://github.com/user-attachments/assets/7791c877-d7ca-4d86-8720-adf43f1a67e9) |

This implementation of motion blur ignores the middle of the screen, so the middle stays sharp. Then it rolls of to the edge. There are 3 variables:
- Inner Circle which anything in the middle of the circle stays sharp. 
- Outer Circle which anything inbetween inner and outer has a motion blur rolloff, and anything outside outer has full motion blur
- Vertical which because some games like Halo has their crosshair not centered, so this allows the user to move the motion blur.

There's also visualization to finetune.

Default settings mimick Halo Reach's setting.

Currently it's only implemented on High Quality Motion Blur setting.

To use, refer to original github repo: https://github.com/vortigern11/vort_Shaders